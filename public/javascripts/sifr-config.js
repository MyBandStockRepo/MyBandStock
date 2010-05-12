var gothambook = {
      src: '/flash/Gotham-Book.swf'
};

var gothammedium = {
      src: '/flash/Gotham-Medium.swf'
};

sIFR.activate(gothambook,gothammedium);



sIFR.replace(gothammedium, {
	selector: '#content-utility.control-panel #utility-overview h2',
	css: [
	'.sIFR-root { font-size:22px; font-weight:normal; color:#ff9900; line-height: -111px; background: #000;}',
	'strong{display: block; font-size: 50%; font-weight: normal;color:#666666; line-height: 1px;}'
	],
	wmode: 'transparent',
	forceWidth: true
	
});

sIFR.replace(gothambook, {
	selector: '.widget-box h2,#stage h2,#application-fan-home #primary-content #news h2, h3.top-bands, #mail .widget-box h3',
	css: [
	'.sIFR-root { font-size:16px; font-weight:normal; color:#ffffff; text-transform: uppercase; background: #000;}',
	],
	wmode: 'transparent',
	offsetTop: 2,
	forceWidth: true
});

	sIFR.replace(gothambook, {
	selector: 'h2.manage-fans,h2.manage-budget,h2.manage-perks ',
	css: [
	'.sIFR-root { font-size:20px; font-weight:normal; color:#ffffff; text-transform: uppercase; background: #000;}',
	],
	wmode: 'transparent',
	offsetTop: -4

});



sIFR.replace(gothambook, {
	selector: '.perks #overview-secondary h3',
	css: [
	'.sIFR-root { font-size:16px; font-weight:normal; color:#FFD3B9; text-transform: uppercase;}',
	],
	wmode: 'transparent',
	offsetTop: 0

});

sIFR.replace(gothambook, {
	selector: '#content-primary.artists h2',
	css: [
	'.sIFR-root { font-size:18px; font-weight:normal; color:#ffffff; text-transform: uppercase;}',
	],
	wmode: 'transparent',
	offsetTop: 2,
	forceWidth: true
});


sIFR.replace(gothambook, {
	selector: '#home-uvp p',
	css: [
	'.sIFR-root { font-size:18px; font-weight:normal; color:#000000; leading: 15; }',
	'strong{font-size:150%; color: #00000; font-weight: bold;}'
	],
	wmode: 'transparent'

});

sIFR.replace(gothammedium, {
	selector: '#how-it-works h3',
	css: [
	'.sIFR-root { font-size:20px; font-weight:normal; color:#666666 }',
	],
	wmode: 'transparent'

});

sIFR.replace(gothammedium, {
	selector: '#help-articles-faq #content h3, #corporate-press #content h3, .info h2, #legal-privacy-policy #content h3',
	css: [
	'.sIFR-root { font-size:20px; font-weight:normal; color:#ff9900; text-transform: uppercase}',
	],
	wmode: 'transparent'

});

sIFR.replace(gothammedium, {
	selector: '#corporate-about #content h3',
	css: [
	'.sIFR-root { font-size:20px; font-weight:normal; color:#ff9900 }',
	],
	wmode: 'transparent'

});
sIFR.replace(gothammedium, {
	selector: 'h1 strong',
	css: [
	'.sIFR-root { font-size:14px; font-weight:normal; color:#ffffff; }',
	],
	wmode: 'transparent'

});
sIFR.replace(gothambook, {
	selector: '#bio h3',
	css: [
	'.sIFR-root { font-size:14px; font-weight:normal; color:#ff9900; text-transform: uppercase;}',
	],
	wmode: 'transparent'
});