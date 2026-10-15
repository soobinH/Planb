document.addEventListener("DOMContentLoaded", function () {
	const tabs = document.querySelectorAll("[data-search-tab]");
	const sections = document.querySelectorAll("[data-search-section]");
	const searchDescription = document.getElementById("searchDescription");

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

			if (searchDescription) {
				if (target === "all") {
					searchDescription.textContent =
						"여행일정 · 여행꿀팁 · 여행 메이트를 한 번에 검색합니다.";
				} else if (target === "schedule") {
					searchDescription.textContent =
						"여행일정에 대한 검색 내용입니다.";
				} else if (target === "tip") {
					searchDescription.textContent =
						"여행꿀팁에 대한 검색 내용입니다.";
				} else if (target === "mate") {
					searchDescription.textContent =
						"여행 메이트에 대한 검색 내용입니다.";
				}
			}
		});
	});
});