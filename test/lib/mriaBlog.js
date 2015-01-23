describe("DOM Tests", function () {
	it("has the right text", function () {
		expect($('h1').get(0).innerText).to.equal('阿富汗“囚犯”眼中的美军监狱');
	});

	it("get game ad module", function () {
		var el = $('#pl-float-bar').get(0);
		expect(el).to.not.equal(null);
	});

	it("change user agent", function () {
		var ua = navigator.userAgent;
		expect(ua).to.equal("androidWebkit");
	});
});