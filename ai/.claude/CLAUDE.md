<claude_spec version="1.2">
  <meta>
    <title>CLAUDE Code & Bookmark Policy</title>
    <audience>Contributors</audience>
  </meta>

  <policies>
    <policy id="comments">
      <summary>Do not add code comments unless they contain information not encoded in code. Keep existing comments.</summary>
      <rules>
        <rule>When adding code, omit comments that only restate what the code expresses.</rule>
        <rule>If necessary, create small, named methods or local/nested functions to encode intent instead of comments.</rule>
        <rule>Preserve all existing comments in touched files.</rule>
      </rules>
    </policy>

    <policy id="bookmarks">
      <summary>Use editor bookmark helpers to mark findings after deeper code research.</summary>
      <tools>
        <tool name="vscode">add_vscode_bookmark '/abs/path/file:line' 'Label'</tool>
        <tool name="xcode">add_xcode_bookmark '/abs/path/file:line' 'Label'</tool>
      </tools>
      <constraints>
        <constraint>Put all bookmarks into vscode <toolref name="vscode"/>.</constraint>
        <constraint>For source files (.swift, .mm but not .plist and .entitlements) in the iOS folder, also use <toolref name="xcode"/>.</constraint>
      </constraints>
      <label_format>
        <pattern>{Number}. {from}-{to}: {Description} ({file})</pattern>
        <guidelines>
          <guideline>Use a sequential Number for organization.</guideline>
          <guideline>Keep Description brief and purpose-focused.</guideline>
        </guidelines>
      </label_format>
    </policy>

    <policy id="uncertainty">
      <summary>If unsure about something, explicitly say so, ask for permission, and only then proceed assuming it's true.</summary>
      <rules>
        <rule>When uncertain, respond with a clear admission of uncertainty (e.g. “I’m not certain…” or “That isn’t fully clear…”).</rule>
        <rule>Then ask for permission before making any assumptions (e.g. “Would you like me to proceed under the assumption that …?”).</rule>
        <rule>If permission is granted (explicitly or implicitly), state your assumption and proceed under that assumption as if it were factual.</rule>
      </rules>
    </policy>

    <policy id="functions">
      <summary>Make function scope explicit, names descriptive, and bodies small. Prefer nested functions for local intent.</summary>
      <rules>
        <rule>If a function is not exported/public, mark it private by prefixing its name with an underscore.</rule>
        <rule>Function names must fully describe what the function does; avoid vague verbs and abbreviations.</rule>
        <rule>When a function grows large or handles multiple concerns, split it into smaller functions each with a single responsibility.</rule>
        <rule>Instead of inline comments, extract logic into nested functions with descriptive names.</rule>
        <rule>If a function’s behavior changes, rename it to reflect its new responsibility.</rule>
      </rules>
      <naming_guidelines>
        <guideline>Prefer verb-first phrases for actions (e.g., <example>calculateMonthlyInvoiceTotals</example>).</guideline>
        <guideline>Encode key inputs/outputs in the name when ambiguous.</guideline>
        <guideline>Use consistent prefixes/suffixes across the codebase (fetch/get/load, create/build, save/persist, parse/format, sync/refresh).</guideline>
      </naming_guidelines>
      <size_guidelines>
        <guideline>Keep control flow flat; extract branches into helpers instead of deep nesting.</guideline>
        <guideline>Enforce single-responsibility; one reason to change.</guideline>
        <guideline>When helpers are only relevant inside a parent function, define them as nested/local functions to signal scoping.</guideline>
      </size_guidelines>
    </policy>
  </policies>

  <examples>
    <example id="bookmark">
      <context>Bookmarking Info.plist settings</context>
      <commands>
        <cmd>add_vscode_bookmark '/path/Info.plist:32' '1. 32-34: Network permissions settings (Info.plist)'</cmd>
      </commands>
    </example>

    <example id="bookmark">
      <context>Bookmarking generic source file</context>
      <commands>
        <cmd>add_vscode_bookmark '/path/AuthService.ts:145' '2. 145-159: JWT token validation logic (AuthService.ts)'</cmd>
      </commands>
    </example>

    <example id="bookmark">
      <context>Bookmarking ios source file in both locations</context>
      <commands>
        <cmd>add_vscode_bookmark '/path/EXKernelLinkingManager.m:70' '3. 70-150: iOS Native Deeplink Handler: Resolving slugs and handling universal links (EXKernelLinkingManager.m)'</cmd>
        <cmd>add_xcode_bookmark '/path/EXKernelLinkingManager.m:70' '3. 70-150: iOS Native Deeplink Handler: Resolving slugs and handling universal links (EXKernelLinkingManager.m)'</cmd>
      </commands>
    </example>

    <example id="uncertainty-ask">
      <context>When unsure whether an API returns null or empty list</context>
      <dialogue>
        <assistant>I’m not entirely sure whether the API may return `null` or just an empty list here. Would you like me to proceed assuming it returns an empty list?</assistant>
      </dialogue>
    </example>

    <example id="uncertainty-proceed">
      <context>After receiving implicit approval</context>
      <dialogue>
        <assistant>Thanks. I’ll proceed under the assumption that the API returns an empty list, and implement defensive handling accordingly.</assistant>
      </dialogue>
    </example>

    <example id="functions-private">
      <context>Marking non-exported helper private</context>
      <before>
        <code>function parseUserRow(row) { /* ... */ }</code>
      </before>
      <after>
        <code>function _parseUserRow(row) { /* ... */ }</code>
      </after>
    </example>

    <example id="functions-nested">
      <context>Replacing inline comments with nested functions</context>
      <before>
        <code>
export function calculateAndPersistMonthlyInvoices(data) {
  // validate inputs
  if (!data) throw new Error("Missing data")
  // calculate totals
  const totals = data.map(/* ... */)
  // persist to database
  saveToDb(totals)
}
        </code>
      </before>
      <after>
        <code>
export function calculateAndPersistMonthlyInvoices(data) {
  function _validateInputs(data) {
    if (!data) throw new Error("Missing data")
  }
  function _calculateTotals(data) {
    return data.map(/* ... */)
  }
  function _persistToDatabase(rows) {
    saveToDb(rows)
  }

  _validateInputs(data)
  const totals = _calculateTotals(data)
  _persistToDatabase(totals)
}
        </code>
      </after>
    </example>
  </examples>

  <formatting_notes>
    <note>Use absolute paths where possible.</note>
    <note>Use 1-based line numbers as displayed in the editor.</note>
  </formatting_notes>
</claude_spec>
