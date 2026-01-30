'use strict';

const { execSync } = require('child_process');

function runCommand(command) {
	try {
		const stdout = execSync(command, { stdio: 'pipe' }).toString();
		return stdout;
	} catch (error) {
		const stderr = error.stderr ? error.stderr.toString() : '';
		const stdout = error.stdout ? error.stdout.toString() : '';
		const message = [stderr.trim(), stdout.trim(), error.message || ''].filter(Boolean).join('\n');
		throw new Error(message);
	}
}

function runCommandJson(command) {
	const needsJson = !/\s--json(\s|$)/.test(command) && !/--result-format\s+json/.test(command);
	const output = runCommand(`${command}${needsJson ? ' --json' : ''}`);
	try {
		return JSON.parse(output);
	} catch (e) {
		throw new Error(`Failed to parse JSON from: ${command}\nOutput: ${output}`);
	}
}

function normalizeWebsite(input) {
	if (!input) return '';
	const cleaned = input
		.trim()
		.replace(/^https?:\/\//i, '')
		.replace(/^www\./i, '')
		.split('/')[0];
	return cleaned.toLowerCase();
}

function deriveBrandFromDomain(domain) {
	if (!domain) return 'Demo';
	const base = domain.split('.')[0];
	if (!base) return 'Demo';
	return base
		.split('-')
		.map((p) => p.charAt(0).toUpperCase() + p.slice(1))
		.join(' ');
}

function generateProductCatalog(brand, numProducts) {
	const baseProducts = [
		{ suffix: 'Starter', family: 'Subscription', price: 29 },
		{ suffix: 'Professional', family: 'Subscription', price: 99 },
		{ suffix: 'Enterprise', family: 'Subscription', price: 299 },
		{ suffix: 'Support', family: 'Services', price: 19 },
		{ suffix: 'Analytics', family: 'Add-on', price: 49 },
		{ suffix: 'Automation', family: 'Add-on', price: 59 },
		{ suffix: 'Integrations', family: 'Add-on', price: 79 },
		{ suffix: 'Security', family: 'Add-on', price: 89 }
	];

	const products = [];
	for (let i = 0; i < Math.max(1, Math.min(numProducts, baseProducts.length)); i += 1) {
		const def = baseProducts[i];
		products.push({
			name: `${brand} ${def.suffix}`,
			family: def.family,
			price: def.price
		});
	}
	return products;
}

function ensureCliAvailable() {
	runCommand('sf --version');
}

function getDefaultCurrencyIso(targetOrg) {
	try {
		const q = 'SELECT IsoCode, IsCorporate FROM CurrencyType WHERE IsActive = true ORDER BY IsCorporate DESC LIMIT 1';
		const output = runCommand(`sf data query --query "${q}" --result-format json${targetOrg ? ` --target-org ${targetOrg}` : ''}`);
		const parsed = JSON.parse(output);
		const recs = (parsed && parsed.result && Array.isArray(parsed.result.records)) ? parsed.result.records : [];
		if (recs.length > 0 && recs[0].IsoCode) {
			return recs[0].IsoCode;
		}
		return null;
	} catch (_) {
		return null;
	}
}

function ensureStandardPricebookActive(targetOrg) {
	const query = "SELECT Id, Name, IsActive FROM Pricebook2 WHERE IsStandard = true";
	// Use result-format json and parse directly to avoid mixing with --json
	const output = runCommand(`sf data query --query "${query}" --result-format json${targetOrg ? ` --target-org ${targetOrg}` : ''}`);
	let records = [];
	try {
		const parsed = JSON.parse(output);
		if (Array.isArray(parsed)) {
			records = parsed;
		} else if (parsed && Array.isArray(parsed.records)) {
			records = parsed.records;
		} else if (parsed && parsed.result && Array.isArray(parsed.result.records)) {
			records = parsed.result.records;
		}
	} catch (e) {
		throw new Error(`Could not parse query output. Raw output:\n${output}`);
	}
	if (!records.length) {
		throw new Error('Standard Price Book not found in target org.');
	}
	const std = records[0];
	if (!std.IsActive) {
		runCommand(`sf data update record --sobject Pricebook2 --record-id ${std.Id} --values "IsActive=true"${targetOrg ? ` --target-org ${targetOrg}` : ''}`);
	}
	return { id: std.Id, isStandard: true };
}

function createProduct(product, targetOrg) {
	const productCode = `${product.name.replace(/[^a-z0-9]/gi, '').slice(0, 20)}-${Date.now().toString().slice(-6)}`;
	const values = [
		`Name=${escapeValue(product.name)}`,
		`ProductCode=${escapeValue(productCode)}`,
		`Family=${escapeValue(product.family)}`,
		'IsActive=true'
	].join(' ');
	const res = runCommandJson(`sf data create record --sobject Product2 --values "${values}"${targetOrg ? ` --target-org ${targetOrg}` : ''}`);
	return res && res.result && res.result.id ? res.result.id : null;
}

function createPricebookEntry(pricebookId, productId, unitPrice, targetOrg, options = {}) {
	const { isStandardPricebook = false } = options;
	const priceValue = Number(unitPrice);
	const priceValueStr = Number.isFinite(priceValue) ? priceValue.toFixed(2) : '0';
	const pairs = [
		`Pricebook2Id=${pricebookId}`,
		`Product2Id=${productId}`,
		`UnitPrice=${priceValueStr}`,
		'IsActive=true'
	];
	// Add currency if org uses multi-currency
	const currencyIso = getDefaultCurrencyIso(targetOrg);
	if (currencyIso) {
		pairs.push(`CurrencyIsoCode=${currencyIso}`);
	}
	// Never set UseStandardPrice here; omitting it works for both standard and custom price books
	const sfValues = pairs.join(' ');
	try {
		return runCommandJson(`sf data create record --sobject PricebookEntry --values "${sfValues}"${targetOrg ? ` --target-org ${targetOrg}` : ''}`);
	} catch (e) {
		// Fallback to legacy sfdx implementation with space-delimited pairs
		try {
			const sfdxValues = pairs.join(' ');
			const sfdxCmd = `sfdx force:data:record:create -s PricebookEntry -v "${sfdxValues}"${targetOrg ? ` -o ${targetOrg}` : ''}`;
			return runCommand(sfdxCmd);
		} catch (e2) {
			// Last attempt: use Apex anonymous
			const currencyClause = currencyIso ? `, CurrencyIsoCode='${currencyIso}'` : '';
			const apex = `PricebookEntry p = new PricebookEntry(Pricebook2Id='${pricebookId}', Product2Id='${productId}', UnitPrice=${priceValueStr}, IsActive=true${currencyClause}); insert p;`;
			const apexCmd = `sf apex run --code "${apex}"${targetOrg ? ` --target-org ${targetOrg}` : ''}`;
			return runCommand(apexCmd);
		}
	}
}

function escapeValue(v) {
	if (v == null) return '';
	const needsQuotes = /[\s,]/.test(String(v));
	if (!needsQuotes) return String(v);
	return `'${String(v).replace(/'/g, "\\'")}'`;
}

function printUsage() {
	console.log('Usage:');
	console.log('  node scripts/generate-products.js <website> [numProducts] [targetOrg]');
	console.log('Examples:');
	console.log('  node scripts/generate-products.js techcorp.com');
	console.log('  node scripts/generate-products.js example.com 5');
	console.log('  node scripts/generate-products.js retail.io 6 my-alias');
}

function main() {
	const args = process.argv.slice(2);
	const [websiteInput, numProductsInput, targetOrg] = args;
	if (!websiteInput) {
		printUsage();
		process.exit(1);
	}

	try {
		ensureCliAvailable();
		const website = normalizeWebsite(websiteInput);
		const brand = deriveBrandFromDomain(website);
		const numProducts = Math.max(1, Math.min(parseInt(numProductsInput || '5', 10) || 5, 8));
		const target = targetOrg || 'second-org';

		console.log(`\n🎯 Generating ${numProducts} products for '${website}' (brand: ${brand})...`);
		console.log(`🗝️  Target org: ${target}`);
		const catalog = generateProductCatalog(brand, numProducts);

		console.log('🔧 Ensuring Standard Price Book is active...');
		const stdPb = ensureStandardPricebookActive(target);

		const created = [];
		for (const p of catalog) {
			console.log(`🛠️  Creating Product2: ${p.name} (Family: ${p.family})`);
			const productId = createProduct(p, target);
			if (!productId) throw new Error('Failed to create Product2.');
			created.push({ ...p, id: productId });
		}

		for (const p of created) {
			console.log(`💲 Creating PricebookEntry for ${p.name} at $${p.price}`);
			createPricebookEntry(stdPb.id, p.id, p.price, target, { isStandardPricebook: stdPb.isStandard });
		}

		console.log(`\n✅ Created ${created.length} products and associated standard price entries.`);
		console.log('👉 Next steps:');
		console.log('   - View products in Salesforce: App Launcher > Products');
		console.log('   - Add products to opportunities via Price Book if needed');
	} catch (e) {
		console.error(`\n❌ Failed: ${e.message}`);
		process.exit(1);
	}
}

main();


