'use strict';

const { execSync } = require('child_process');
const readline = require('readline');

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout
});

function question(prompt) {
	return new Promise((resolve) => {
		rl.question(prompt, resolve);
	});
}

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

function getAvailableOrgs() {
	try {
		const output = runCommand('sf org list --all --json');
		const result = JSON.parse(output);
		return result.result || [];
	} catch (e) {
		return [];
	}
}

function getProductTemplates() {
	return {
		'Technology': [
			{ name: 'Cloud Platform', family: 'Software', price: 299 },
			{ name: 'Data Analytics', family: 'Software', price: 199 },
			{ name: 'Security Suite', family: 'Software', price: 399 },
			{ name: 'API Integration', family: 'Services', price: 150 },
			{ name: 'Consulting', family: 'Services', price: 250 },
			{ name: 'Training', family: 'Services', price: 100 }
		],
		'Healthcare': [
			{ name: 'Patient Management', family: 'Software', price: 450 },
			{ name: 'Electronic Health Records', family: 'Software', price: 600 },
			{ name: 'Telemedicine Platform', family: 'Software', price: 350 },
			{ name: 'Compliance Consulting', family: 'Services', price: 300 },
			{ name: 'Implementation', family: 'Services', price: 200 },
			{ name: 'Support & Maintenance', family: 'Services', price: 150 }
		],
		'Financial Services': [
			{ name: 'Risk Management', family: 'Software', price: 500 },
			{ name: 'Compliance Platform', family: 'Software', price: 400 },
			{ name: 'Trading System', family: 'Software', price: 800 },
			{ name: 'Audit Services', family: 'Services', price: 350 },
			{ name: 'Regulatory Consulting', family: 'Services', price: 400 },
			{ name: 'System Integration', family: 'Services', price: 250 }
		],
		'Manufacturing': [
			{ name: 'ERP System', family: 'Software', price: 750 },
			{ name: 'Quality Control', family: 'Software', price: 300 },
			{ name: 'Supply Chain Management', family: 'Software', price: 450 },
			{ name: 'Process Optimization', family: 'Services', price: 200 },
			{ name: 'Equipment Maintenance', family: 'Services', price: 150 },
			{ name: 'Training Programs', family: 'Services', price: 100 }
		],
		'Retail': [
			{ name: 'POS System', family: 'Software', price: 200 },
			{ name: 'Inventory Management', family: 'Software', price: 150 },
			{ name: 'E-commerce Platform', family: 'Software', price: 300 },
			{ name: 'Customer Analytics', family: 'Services', price: 180 },
			{ name: 'Store Setup', family: 'Services', price: 120 },
			{ name: 'Staff Training', family: 'Services', price: 80 }
		],
		'Distribution': [
			{ name: 'Import Services', family: 'Services', price: 250 },
			{ name: 'Export Solutions', family: 'Services', price: 200 },
			{ name: 'Customs Clearance', family: 'Services', price: 150 },
			{ name: 'Logistics Management', family: 'Software', price: 300 },
			{ name: 'Warehouse Services', family: 'Services', price: 180 },
			{ name: 'Supply Chain Solutions', family: 'Software', price: 400 }
		],
		'Custom': []
	};
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

function createPricebookEntry(pricebookId, productId, unitPrice, targetOrg) {
	const priceValue = Number(unitPrice);
	const priceValueStr = Number.isFinite(priceValue) ? priceValue.toFixed(2) : '0';
	const pairs = [
		`Pricebook2Id=${pricebookId}`,
		`Product2Id=${productId}`,
		`UnitPrice=${priceValueStr}`,
		'IsActive=true'
	];
	const sfValues = pairs.join(' ');
	try {
		return runCommandJson(`sf data create record --sobject PricebookEntry --values "${sfValues}"${targetOrg ? ` --target-org ${targetOrg}` : ''}`);
	} catch (e) {
		try {
			const sfdxValues = pairs.join(' ');
			const sfdxCmd = `sfdx force:data:record:create -s PricebookEntry -v "${sfdxValues}"${targetOrg ? ` -o ${targetOrg}` : ''}`;
			return runCommand(sfdxCmd);
		} catch (e2) {
			const apex = `PricebookEntry p = new PricebookEntry(Pricebook2Id='${pricebookId}', Product2Id='${productId}', UnitPrice=${priceValueStr}, IsActive=true); insert p;`;
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

async function main() {
	console.log('🚀 Quick Product Generator for SE Demos');
	console.log('=====================================\n');

	try {
		// Check CLI availability
		runCommand('sf --version');
		console.log('✅ Salesforce CLI detected\n');

		// Get available orgs
		const orgs = getAvailableOrgs();
		let targetOrg = '';

		if (orgs.length === 0) {
			console.log('❌ No orgs found. Please authenticate first:');
			console.log('   sf org login web --alias your-org-alias');
			process.exit(1);
		}

		// Select org
		console.log('Available orgs:');
		orgs.forEach((org, index) => {
			console.log(`   ${index + 1}. ${org.alias || org.username} (${org.orgId})`);
		});

		const orgChoice = await question('\nSelect org (number) or enter alias: ');
		const orgIndex = parseInt(orgChoice) - 1;
		
		if (orgIndex >= 0 && orgIndex < orgs.length) {
			targetOrg = orgs[orgIndex].alias || orgs[orgIndex].username;
		} else {
			targetOrg = orgChoice;
		}

		// Get company info
		const companyName = await question('Enter company name: ');
		if (!companyName.trim()) {
			console.log('❌ Company name is required');
			process.exit(1);
		}

		// Select product template
		const templates = getProductTemplates();
		console.log('\nProduct templates:');
		Object.keys(templates).forEach((template, index) => {
			console.log(`   ${index + 1}. ${template}`);
		});

		const templateChoice = await question('\nSelect template (number) or enter "Custom": ');
		const templateIndex = parseInt(templateChoice) - 1;
		let selectedTemplate = 'Custom';
		
		if (templateIndex >= 0 && templateIndex < Object.keys(templates).length) {
			selectedTemplate = Object.keys(templates)[templateIndex];
		} else if (templateChoice.trim()) {
			selectedTemplate = templateChoice.trim();
		}

		let products = [];
		if (selectedTemplate === 'Custom') {
			// Custom products
			console.log('\nEnter custom products (press Enter twice when done):');
			let productCount = 1;
			while (true) {
				const productName = await question(`Product ${productCount} name: `);
				if (!productName.trim()) break;
				
				const family = await question(`Product ${productCount} family (Software/Services/Hardware): `) || 'Software';
				const price = await question(`Product ${productCount} price ($): `) || '100';
				
				products.push({
					name: productName.trim(),
					family: family.trim(),
					price: parseInt(price) || 100
				});
				productCount++;
			}
		} else {
			// Use template
			products = templates[selectedTemplate];
			const numProducts = await question(`\nHow many products to create (1-${products.length})? `);
			const count = parseInt(numProducts) || products.length;
			products = products.slice(0, Math.min(count, products.length));
		}

		if (products.length === 0) {
			console.log('❌ No products specified');
			process.exit(1);
		}

		// Confirm and create
		console.log(`\n📋 Summary:`);
		console.log(`   Company: ${companyName}`);
		console.log(`   Template: ${selectedTemplate}`);
		console.log(`   Target Org: ${targetOrg}`);
		console.log(`   Products: ${products.length}`);
		products.forEach((p, i) => {
			console.log(`     ${i + 1}. ${p.name} (${p.family}) - $${p.price}`);
		});

		const confirm = await question('\nProceed? (y/N): ');
		if (confirm.toLowerCase() !== 'y' && confirm.toLowerCase() !== 'yes') {
			console.log('❌ Cancelled');
			process.exit(0);
		}

		// Create products
		console.log('\n🔧 Ensuring Standard Price Book is active...');
		const stdPb = ensureStandardPricebookActive(targetOrg);

		const created = [];
		for (const p of products) {
			console.log(`🛠️  Creating Product2: ${p.name} (Family: ${p.family})`);
			const productId = createProduct(p, targetOrg);
			if (!productId) throw new Error('Failed to create Product2.');
			created.push({ ...p, id: productId });
		}

		for (const p of created) {
			console.log(`💲 Creating PricebookEntry for ${p.name} at $${p.price}`);
			createPricebookEntry(stdPb.id, p.id, p.price, targetOrg);
		}

		console.log(`\n✅ Successfully created ${created.length} products in ${targetOrg}!`);
		console.log('\n👉 Next steps:');
		console.log(`   - Open org: sf org open --target-org ${targetOrg}`);
		console.log('   - View products: App Launcher > Products');
		console.log('   - Add to opportunities via Price Book');

	} catch (e) {
		console.error(`\n❌ Failed: ${e.message}`);
		process.exit(1);
	} finally {
		rl.close();
	}
}

main();










