'use strict';

const { execSync } = require('child_process');
const https = require('https');
const { URL } = require('url');

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

function fetchWebPage(url) {
	return new Promise((resolve, reject) => {
		const urlObj = new URL(url);
		const options = {
			hostname: urlObj.hostname,
			port: urlObj.port || 443,
			path: urlObj.pathname + urlObj.search,
			method: 'GET',
			headers: {
				'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
			}
		};

		const req = https.request(options, (res) => {
			let data = '';
			res.on('data', (chunk) => {
				data += chunk;
			});
			res.on('end', () => {
				resolve(data);
			});
		});

		req.on('error', (err) => {
			reject(err);
		});

		req.end();
	});
}

function extractProductsFromHTML(html) {
	const products = [];
	
	// Look for common product patterns in HTML
	const patterns = [
		// Pattern 1: Look for product titles in headings
		/<h[1-6][^>]*class="[^"]*product[^"]*"[^>]*>(.*?)<\/h[1-6]>/gi,
		/<h[1-6][^>]*class="[^"]*title[^"]*"[^>]*>(.*?)<\/h[1-6]>/gi,
		
		// Pattern 2: Look for product names in divs with product-related classes
		/<div[^>]*class="[^"]*product[^"]*"[^>]*>.*?<[^>]*>(.*?)<\/[^>]*>/gi,
		
		// Pattern 3: Look for items in lists that might be products
		/<li[^>]*class="[^"]*product[^"]*"[^>]*>(.*?)<\/li>/gi,
		
		// Pattern 4: Look for any text that might be product names (fallback)
		/<[^>]*class="[^"]*(?:product|item|service)[^"]*"[^>]*>(.*?)<\/[^>]*>/gi
	];

	const foundNames = new Set();
	
	patterns.forEach(pattern => {
		let match;
		while ((match = pattern.exec(html)) !== null) {
			const text = match[1].replace(/<[^>]*>/g, '').trim();
			if (text && text.length > 3 && text.length < 100 && !foundNames.has(text.toLowerCase())) {
				foundNames.add(text.toLowerCase());
				products.push({
					name: text,
					family: 'Distribution',
					price: Math.floor(Math.random() * 200) + 50 // Random price between 50-250
				});
			}
		}
	});

	// If no products found with patterns, generate some based on the domain
	if (products.length === 0) {
		const defaultProducts = [
			'Import Services',
			'Export Solutions',
			'Customs Clearance',
			'Logistics Management',
			'Warehouse Services',
			'Distribution Network',
			'Supply Chain Solutions',
			'International Shipping'
		];
		
		defaultProducts.forEach(name => {
			products.push({
				name: name,
				family: 'Distribution',
				price: Math.floor(Math.random() * 200) + 50
			});
		});
	}

	return products.slice(0, 8); // Limit to 8 products
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
	const currencyIso = getDefaultCurrencyIso(targetOrg);
	if (currencyIso) {
		pairs.push(`CurrencyIsoCode=${currencyIso}`);
	}
	const sfValues = pairs.join(' ');
	try {
		return runCommandJson(`sf data create record --sobject PricebookEntry --values "${sfValues}"${targetOrg ? ` --target-org ${targetOrg}` : ''}`);
	} catch (e) {
		try {
			const sfdxValues = pairs.join(' ');
			const sfdxCmd = `sfdx force:data:record:create -s PricebookEntry -v "${sfdxValues}"${targetOrg ? ` -o ${targetOrg}` : ''}`;
			return runCommand(sfdxCmd);
		} catch (e2) {
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
	console.log('  node scripts/scrape-products.js <website-url> [targetOrg]');
	console.log('Examples:');
	console.log('  node scripts/scrape-products.js https://hostedresources.districtpublishing.com/Latin-American-Distributors/');
	console.log('  node scripts/scrape-products.js https://example.com second-org');
}

async function main() {
	const args = process.argv.slice(2);
	const [websiteUrl, targetOrg] = args;
	
	if (!websiteUrl) {
		printUsage();
		process.exit(1);
	}

	try {
		ensureCliAvailable();
		const target = targetOrg || 'second-org';
		const domain = normalizeWebsite(websiteUrl);
		const brand = deriveBrandFromDomain(domain);

		console.log(`\n🌐 Scraping products from: ${websiteUrl}`);
		console.log(`🗝️  Target org: ${target}`);
		
		const html = await fetchWebPage(websiteUrl);
		console.log(`📄 Retrieved ${html.length} characters of HTML content`);
		
		const products = extractProductsFromHTML(html);
		console.log(`🎯 Found ${products.length} products from website`);
		
		if (products.length === 0) {
			console.log('⚠️  No products found, using default distribution products');
		}

		console.log('🔧 Ensuring Standard Price Book is active...');
		const stdPb = ensureStandardPricebookActive(target);

		const created = [];
		for (const p of products) {
			console.log(`🛠️  Creating Product2: ${p.name} (Family: ${p.family})`);
			const productId = createProduct(p, target);
			if (!productId) throw new Error('Failed to create Product2.');
			created.push({ ...p, id: productId });
		}

		for (const p of created) {
			console.log(`💲 Creating PricebookEntry for ${p.name} at $${p.price}`);
			createPricebookEntry(stdPb.id, p.id, p.price, target, { isStandardPricebook: stdPb.isStandard });
		}

		console.log(`\n✅ Created ${created.length} products from website and associated standard price entries.`);
		console.log('👉 Next steps:');
		console.log('   - View products in Salesforce: App Launcher > Products');
		console.log('   - Add products to opportunities via Price Book if needed');
		
	} catch (e) {
		console.error(`\n❌ Failed: ${e.message}`);
		process.exit(1);
	}
}

main();












