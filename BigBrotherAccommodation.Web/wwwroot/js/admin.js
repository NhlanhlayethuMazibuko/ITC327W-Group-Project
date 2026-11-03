// Staff portal behaviour: list filters, stage form and viewing response form.
(function () {
    "use strict";

    // ---- Lists: search, filter and sort rows already on the page ----
    document.querySelectorAll("[data-list]").forEach(function (list) {
        var search = list.querySelector("[data-list-search]");
        var filters = list.querySelectorAll("[data-list-filter]");
        var sort = list.querySelector("[data-list-sort]");
        var body = list.querySelector("[data-list-body]");
        var empty = list.querySelector("[data-list-empty]");
        if (!body) return;

        var rows = Array.prototype.slice.call(body.querySelectorAll("[data-row]"));

        function update() {
            var term = search ? search.value.trim().toLowerCase() : "";
            var wanted = filter ? filter.value : "";
            var shown = 0;

            rows.forEach(function (row) {
                var matchesText = !term || (row.getAttribute("data-search") || "").indexOf(term) !== -1;
                var matchesFilter = !wanted || row.getAttribute("data-filter") === wanted;
                var visible = matchesText && matchesFilter;
                row.hidden = !visible;
                if (visible) shown++;
            });

            if (sort) {
                var oldest = sort.value === "oldest";
                rows.sort(function (a, b) {
                    var x = Number(a.getAttribute("data-sort")) || 0;
                    var y = Number(b.getAttribute("data-sort")) || 0;
                    return oldest ? x - y : y - x;
                });
                rows.forEach(function (row) {
                    body.insertBefore(row, empty || null);
                });
            }

            if (empty) empty.hidden = shown !== 0;
        }

        if (search) search.addEventListener("input", update);
        if (filter) filter.addEventListener("change", update);
        if (sort) sort.addEventListener("change", update);
        update();
    });

    // ---- Application review: outcome only applies to a decision ----
    var stageForm = document.querySelector("[data-stage-form]");
    if (stageForm) {
        var stage = stageForm.querySelector("[data-stage-select]");
        var outcome = stageForm.querySelector("[data-outcome-select]");

        // Picking an outcome moves the stage to Decision; leaving Decision clears it.
        outcome.addEventListener("change", function () {
            if (outcome.value) stage.value = "decision";
        });
        stage.addEventListener("change", function () {
            if (stage.value !== "decision") outcome.value = "";
        });

        stageForm.addEventListener("submit", function (e) {
            if (stage.value === "decision" && !outcome.value) {
                e.preventDefault();
                outcome.focus();
                alert("Choose an outcome: Approved or Rejected.");
            }
        });
    }

    // ---- Viewing details: alternative date/time only when suggesting one ----
    var responseForm = document.querySelector("[data-response-form]");
    if (responseForm) {
        var response = responseForm.querySelector("[data-response-select]");
        var altFields = responseForm.querySelectorAll("[data-alt-field]");

        function syncAlt() {
            var show = response.value === "alternative";
            altFields.forEach(function (field) {
                field.hidden = !show;
                var input = field.querySelector("select, input");
                if (input) {
                    input.disabled = !show;
                    if (!show) input.value = "";
                }
            });
        }

        response.addEventListener("change", syncAlt);
        syncAlt();

        responseForm.addEventListener("submit", function (e) {
            if (!response.value) {
                e.preventDefault();
                response.focus();
                alert("Choose how you want to respond.");
                return;
            }
            if (response.value === "alternative") {
                var date = responseForm.querySelector("#AltDate");
                var time = responseForm.querySelector("#AltTime");
                if (!date.value || !time.value) {
                    e.preventDefault();
                    alert("Choose an alternative date and time.");
                }
            }
        });
    }
})();