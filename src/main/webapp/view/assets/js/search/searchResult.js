document.addEventListener("DOMContentLoaded", function () {
	const tabs = document.querySelectorAll("[data-search-tab]");
	const sections = document.querySelectorAll("[data-search-section]");

	if (tabs.length === 0 || sections.length === 0) {
		return;
	}

	tabs.forEach(function (tab) {
		tab.addEventListener("click", function () {
			const target = this.getAttribute("data-search-tab");

			tabs.forEach(function (item) {
				item.classList.remove("bg-[#6369D1]", "text-white");
				item.classList.add(
					"bg-white",
					"text-gray-600",
					"border",
					"border-gray-200"
				);
			});

			this.classList.remove(
				"bg-white",
				"text-gray-600",
				"border",
				"border-gray-200"
			);

			this.classList.add(
				"bg-[#6369D1]",
				"text-white"
			);

			sections.forEach(function (section) {
				const sectionName = section.getAttribute("data-search-section");

				if (target === "all" || target === sectionName) {
					section.style.display = "";
				} else {
					section.style.display = "none";
				}
			});
		});
	});
});