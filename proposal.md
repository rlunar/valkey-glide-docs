# Proposal: Unified Documentation Strategy for GLIDE

## Summary

We are proposing a new framework on writing GLIDE documentations moving forward. Instead of maintaining separate documentation silos for each language 
(Python, Java, etc.), we will present GLIDE as a single client implementation that can be used in multiple languages. This change aims to simplify 
our documentation, significantly reduce maintenance overhead from duplicated articles, and ensure readers develop the correct mental model of the 
GLIDE client.

## Motivations

Currently, our documentation features a distinct section for each client language under `languages/`. This approach causes several issues:
* **Incorrect Mental Model:** It creates the false impression that each client is a separate implementation with unique interfaces, rather than a unified one.
* **High Maintenance Overhead:** The current setup promote copy-pasting contents. Updating a core concept also requires editing multiple pages across different language sections, which is time-consuming and prone to human error.
* **Scalability Issues:** Adding new languages increases the volume of redundant text we must manage.

This proposal is critical now due to the upcoming GA release of the PHP and C# clients, and other features in the future. 
Without this change, we will be forced to create and maintain two additional sets of duplicate documentation.

## The Proposal
We propose to update the documentation site to present GLIDE as a single client supporting different language interfaces.

Key Components of the Change:
* **Combining Documentations:** We will combine existing language documentation into shared sections (primarily "How-to" guides).
* **UI Enhancements:** Specific language differences will be handled via UI elements (e.g., toggle tabs for Python/Java/PHP) within a single article, rather than separate articles.
* **Migration Restructuring:** We will reorganize migration guides under `migration/<language>/...` as these remain inherently language-specific.

**Proposed Timeline:** To be completed during 2.3 release.

## Risk Assessment & Mitigation
We have identified the following risks and mitigation strategies:

### Risk: Language Specific Navigation
Some users enter the site with a specific language in mind (e.g., "How to Connect to Valkey with Java"). 
There is a concern that combing the separate `languages/...` directories will make this less intuitive.

In general, we view this as a tradeoff; By shifting away from duplicating documentations, we are able to simplify the docs while focusing on feature-first documentations and still deliver language specific instructions on each page.

The concern is also mitigated by our language selector on the homepage. When selected it takes the user to the Quickstart page with the chosen language selected.

In general, if this continue to be an issue for users, we can make incremental improvements to the site.

### Risk: Specific Language Feature
Some features (e.g., Python Sync Client) may not exist in all languages, potentially confusing users in a unified view.

**Mitigation:** Features that are not available in all languages will be clearly marked.

### Risk: Feature Complexity
While we generally expect high consistency, there is a possibility that instructions for certain features may be too complex or divergent to fit neatly into a single tabbed page without cluttering the UI.

**Mitigation:** In these rare instances, we will utilize a Feature-First hierarchy. We will split the instructions into sub-pages nested under that specific feature topic (e.g., How-to > Auth > Python Setup).

This maintains the correct mental model by starting at the feature level and drilling down to the specific language, as opposed to the old model which started at the language level and siloed features separately.

### Risk: Future Interface Divergence
Over time, client language interfaces might drift apart due to incremental changes or design shifts.

GLIDE’s core objective is to "deliver consistent behavior across multiple languages." If divergence occurs, it indicates a product inconsistency rather than a documentation issue. 
In this case, our documentation strategy would acts as a guardrail, highlighting unwarranted divergence to the team.

## Timeline Impact
We do not anticipate this restructuring to negatively impact the previously proposed release timeline for version 2.3.
