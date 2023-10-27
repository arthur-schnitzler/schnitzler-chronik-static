var project_collection_name = "schnitzler-chronik"

const typesenseInstantsearchAdapter = new TypesenseInstantSearchAdapter({
    server: {
        apiKey: "NzDtJWKq1IXQbpmfA5KeX2QuH4L5iZcD",
        nodes: [
            {
                host: "typesense.acdh-dev.oeaw.ac.at",
                port: "443",
                protocol: "https",
            },
        ],
    },
    additionalSearchParameters: {
        query_by: "full_text",
    },
});

const searchClient = typesenseInstantsearchAdapter.searchClient;
const search = instantsearch({
    searchClient,
    indexName: project_collection_name,
});

search.addWidgets([
    instantsearch.widgets.searchBox({
        container: "#searchbox",
        autofocus: true,
        cssClasses: {
            form: "form-inline",
            input: "form-control col-md-11",
            submit: "btn",
            reset: "btn",
        },
    }),

    instantsearch.widgets.hits({
        container: "#hits",
        cssClasses: {
            item: "w-100"
        },
        templates: {
            empty: "Keine Resultate für <q>{{ query }}</q>",
            item(hit, { html, components }) {
                return html` 
            <h3><a href='${hit.rec_id}'>${hit.title}</a></h3>
            <p>${hit._snippetResult.full_text.matchedWords.length > 0 ? components.Snippet({ hit, attribute: 'full_text' }) : ''}</p>
            `;
            },
        },
    }),

    instantsearch.widgets.pagination({
        container: "#pagination",
    }),

    instantsearch.widgets.stats({
        container: "#stats-container",
        templates: {
            text: `
            {{#areHitsSorted}}
              {{#hasNoSortedResults}}keine Treffer{{/hasNoSortedResults}}
              {{#hasOneSortedResults}}1 Treffer{{/hasOneSortedResults}}
              {{#hasManySortedResults}}{{#helpers.formatNumber}}{{nbSortedHits}}{{/helpers.formatNumber}} Treffer {{/hasManySortedResults}}
              aus {{#helpers.formatNumber}}{{nbHits}}{{/helpers.formatNumber}}
            {{/areHitsSorted}}
            {{^areHitsSorted}}
              {{#hasNoResults}}keine Treffer{{/hasNoResults}}
              {{#hasOneResult}}1 Treffer{{/hasOneResult}}
              {{#hasManyResults}}{{#helpers.formatNumber}}{{nbHits}}{{/helpers.formatNumber}} Treffer{{/hasManyResults}}
            {{/areHitsSorted}}
            gefunden in {{processingTimeMS}}ms
          `,
        },
    }),

    instantsearch.widgets.refinementList({
        container: "#refinement-list-projects",
        attribute: "projects",
        searchable: true,
        cssClasses: {
            showMore: "btn btn-secondary btn-sm align-content-center",
            list: "list-unstyled",
            count: "badge m-2 badge-secondary hideme",
            label: "d-flex align-items-center",
            checkbox: "m-2",
        },
    }),

    instantsearch.widgets.rangeInput({
        container: "#refinement-range-year",
        attribute: "year",
        templates: {
            separatorText: "bis",
            submitText: "Suchen",
        },
        cssClasses: {
            form: "form-inline",
            input: "form-control",
            submit: "btn",
        },
    }),


    instantsearch.widgets.pagination({
        container: "#pagination",
        padding: 2,
        cssClasses: {
            list: "pagination",
            item: "page-item",
            link: "page-link",
        },
    }),

    instantsearch.widgets.clearRefinements({
        container: "#clear-refinements",
        templates: {
            resetLabel: "Filter zurücksetzen",
        },
        cssClasses: {
            button: "btn",
        },
    }),

    instantsearch.widgets.currentRefinements({
        container: "#current-refinements",
        cssClasses: {
            delete: "btn",
            label: "badge",
        },
    }),

    instantsearch.widgets.sortBy({
        container: "#sort-by",
        items: [
            { label: "Jahr (aufsteigend)", value: "schnitzler-chronik/sort/year:asc" },
            { label: "Jahr (absteigend)", value: "schnitzler-chronik/sort/year:desc" },
        ],
    }),

    instantsearch.widgets.configure({
        hitsPerPage: 20,
        attributesToSnippet: ["full_text"],
    }),

]);

search.start();