import { ALL } from './c-surfaces.js';

export const overlays = [
  {
    id: 'sheet', name: 'Bottom sheet', group: 'Overlays and feedback', platforms: ALL,
    summary: 'Paper fill, a 2.5 ink line on top, top radius 24, up to 90% of the screen. Title, content, then the primary button last. Form errors sit inline directly above the button.',
    states: [
      { label: 'Rest', html: '<div class="sp-sheet full" style="border-left:2.5px solid;border-right:2.5px solid"><div class="sp-text-sheet-title">Rename account</div><input class="sp-field__input" placeholder="Account name" aria-label="Account name"><button class="sp-button">Save</button></div>' },
      { label: 'Error', html: '<div class="sp-sheet full" style="border-left:2.5px solid;border-right:2.5px solid"><div class="sp-text-sheet-title">Rename account</div><input class="sp-field__input" value="  " aria-invalid="true" aria-label="Account name"><span class="sp-form-error">Names need at least one letter.</span><button class="sp-button">Save</button></div>' },
    ],
    code: {
      compose: "if (renaming) {\n    PopBottomSheet(onDismiss = { renaming = false }) {\n        PopSheet(\"Rename account\", primaryLabel = \"Save\", onPrimary = ::save, error = error) {\n            PopTextField(name, { name = it }, hint = \"Account name\")\n        }\n    }\n}",
      swift: ".popBottomSheet(isPresented: $renaming) {\n    PopSheet(\"Rename account\", primaryLabel: \"Save\", onPrimary: save, error: error) {\n        PopTextField(\"Account name\", text: $name)\n    }\n}",
      html: "<dialog class=\"sp-sheet\" id=\"rename\">…<button class=\"sp-button\" data-sp-close>Save</button></dialog>\n\nimport { openPop } from '@sticker-pop/web/behaviors';\nopenPop(document.getElementById('rename'));",
      flutter: "showPopSheet<void>(\n  context: context,\n  builder: (_) => PopSheet(\n    title: 'Rename account',\n    error: error,\n    primaryLabel: 'Save',\n    onPrimary: save,\n    children: [PopTextField(controller: name, hint: 'Account name')],\n  ),\n);",
    },
    spec: [['Fill', 'paper'], ['Edge', '2.5 ink line on top only'], ['Radius', '24, top corners'], ['Padding', '20 (24 at the bottom)'], ['Max height', '90% of the screen'], ['Title', '22/800']],
  },
  {
    id: 'dialog', name: 'Dialog', group: 'Overlays and feedback', platforms: ALL,
    summary: 'A paper sticker with the large 6/6 shadow, 20 in from the screen edges. Title, body, the primary button, then "Cancel".',
    states: [
      { label: 'Inline preview', html: '<div class="sp-dialog full" style="margin:0"><div class="sp-text-sheet-title">Delete this transaction?</div><p class="sp-text-body">It goes from this phone straight away. You can undo for a few seconds.</p><button class="sp-button">Delete</button><div style="text-align:center"><button class="sp-text-button">Cancel</button></div></div>' },
      { label: 'Live', html: '<button class="sp-chip" data-dialog="demo-dialog">Open dialog</button><dialog id="demo-dialog" class="sp-dialog" style="max-width:360px;padding:20px"><div class="sp-text-sheet-title">Delete this transaction?</div><p class="sp-text-body">It goes from this phone straight away. You can undo for a few seconds.</p><button class="sp-button" data-close data-snack="Deleted" data-action="Undo">Delete</button><div style="text-align:center"><button class="sp-text-button" data-close>Cancel</button></div></dialog>' },
    ],
    code: {
      compose: "if (confirming) {\n    PopDialog(\n        \"Delete this transaction?\",\n        \"It goes from this phone straight away. You can undo for a few seconds.\",\n        \"Delete\", onPrimary = ::delete, onDismiss = { confirming = false },\n    )\n}",
      swift: ".popDialog(isPresented: $confirming) {\n    PopDialog(\"Delete this transaction?\",\n              message: \"It goes from this phone straight away. You can undo for a few seconds.\",\n              primaryLabel: \"Delete\", onPrimary: delete, onCancel: { confirming = false })\n}",
      flutter: "showPopDialog<void>(\n  context: context,\n  builder: (_) => PopDialog(\n    title: 'Delete this transaction?',\n    body: 'It goes from this phone straight away. You can undo for a few seconds.',\n    primaryLabel: 'Delete',\n    onPrimary: delete,\n  ),\n);",
      html: '<dialog class="sp-dialog">\n  <div class="sp-text-sheet-title">Delete this transaction?</div>\n  <p class="sp-text-body">…</p>\n  <button class="sp-button">Delete</button>\n  <button class="sp-text-button">Cancel</button>\n</dialog>',
    },
    spec: [['Surface', 'paper StickerCard'], ['Shadow', '6/6'], ['Inset', '20 from screen edges'], ['Title / body', '22/800 · 15/600']],
  },
  {
    id: 'menu', name: 'Menu', group: 'Overlays and feedback', platforms: ALL,
    summary: 'A small popover of actions for a row or a screen, opened from a "more" icon button. A white sticker with the 4/4 shadow; rows turn yellow under the finger, pointer or keyboard focus. It opens under its button, lined up with its right edge, and flips above when there is no room.',
    states: [
      { label: 'Open it', html: '<div class="row full" style="justify-content:space-between"><span class="sp-text-row-title">Chai Point</span><button class="sp-icon-button" popovertarget="demo-menu" aria-label="More for Chai Point"><span class="sp-icon">more_horiz</span></button><div class="sp-menu" id="demo-menu" popover><button class="sp-menu__item" data-snack="Edit opens here"><span class="sp-icon">edit</span>Edit</button><button class="sp-menu__item" data-snack="Duplicated"><span class="sp-icon">content_copy</span>Duplicate</button><button class="sp-menu__item" data-snack="Split opens here"><span class="sp-icon">call_split</span>Split</button><hr class="sp-menu__divider"><button class="sp-menu__item sp-menu__item--destructive" data-snack="Deleted" data-action="Undo"><span class="sp-icon">delete</span>Delete</button></div></div>' },
      { label: 'Panel', html: '<div class="sp-menu full" style="max-width:240px"><button class="sp-menu__item"><span class="sp-icon">edit</span>Edit</button><button class="sp-menu__item" style="background:var(--sp-color-yellow)"><span class="sp-icon">content_copy</span>Duplicate</button><button class="sp-menu__item" disabled><span class="sp-icon">share</span>Share</button><hr class="sp-menu__divider"><button class="sp-menu__item sp-menu__item--destructive"><span class="sp-icon">delete</span>Delete</button></div>' },
    ],
    code: {
      flutter: "PopMenu(\n  items: [\n    PopMenuItem(label: 'Edit', icon: Icons.edit_rounded, onTap: edit),\n    PopMenuItem(label: 'Duplicate', icon: Icons.content_copy_rounded, onTap: duplicate),\n    const PopMenuDivider(),\n    PopMenuItem(label: 'Delete', icon: Icons.delete_rounded, destructive: true, onTap: delete),\n  ],\n  builder: (context, toggle, open) => PopIconButton(icon: Icons.more_horiz_rounded, label: 'More', onTap: toggle),\n)",
      compose: 'PopMenu(\n    items = listOf(\n        PopMenuItem("Edit", Icons.Rounded.Edit) { edit() },\n        PopMenuItem("Duplicate", Icons.Rounded.ContentCopy) { duplicate() },\n        PopMenuDivider,\n        PopMenuItem("Delete", Icons.Rounded.Delete, destructive = true) { delete() },\n    ),\n) { toggle, _ -> PopIconButton(Icons.Rounded.MoreHoriz, "More", onClick = toggle) }',
      swift: '// Once, at the root of the screen: .popOverlayHost()\nPopMenu([\n    .item("Edit", systemImage: "pencil") { edit() },\n    .item("Duplicate", systemImage: "doc.on.doc") { duplicate() },\n    .divider,\n    .item("Delete", systemImage: "trash", destructive: true) { delete() },\n]) { toggle in\n    PopIconButton(systemImage: "ellipsis", label: "More", action: toggle)\n}',
      html: '<button class="sp-icon-button" popovertarget="row-menu" aria-label="More">\n  <span class="sp-icon">more_horiz</span>\n</button>\n<div class="sp-menu" id="row-menu" popover>\n  <button class="sp-menu__item"><span class="sp-icon">edit</span>Edit</button>\n  <hr class="sp-menu__divider">\n  <button class="sp-menu__item sp-menu__item--destructive"><span class="sp-icon">delete</span>Delete</button>\n</div>\n\n<script type="module">\n  import { wirePopMenus } from \'@sticker-pop/web/behaviors.mjs\';\n  wirePopMenus();\n</script>',
    },
    spec: [['Panel', 'white, 2.5 outline, radius 16, 4/4 shadow, 6 top and bottom padding'], ['Width', '180 to 280, never past the screen edges (8 margin)'], ['Rows', '48 high, 16 side padding, 22 icon, 15/700 (destructive 800)'], ['Active row', 'yellow fill, edge to edge'], ['Divider', '2 line, 6 above and below'], ['Motion', 'fades and grows from 96% in 150 ms (fade); reduced motion: fade only'], ['Position', 'below the button, right edges lined up; above when there is no room']],
    rules: ['Keep menus short: up to about six actions.', 'Put a destructive action last, after a divider. It stays ink and bold, never red; confirm it with a dialog or offer Undo.', 'Use a select, not a menu, to pick a value.'],
    a11y: 'The button says what it is for ("More for Chai Point") and whether the menu is open. Focus moves into the menu; arrow keys, Home and End move between items; Escape or a tap outside closes it and returns focus to the button.',
  },
  {
    id: 'snackbar', name: 'Snackbar', group: 'Overlays and feedback', platforms: ALL,
    summary: 'Floating, ink fill, radius 16, 15/700 white text with a yellow action. Only for "Saved" and "Deleted · Undo"-style confirmations.',
    states: [
      { label: 'Confirmation', html: '<div class="sp-snackbar full">Saved</div>' },
      { label: 'With action', html: '<div class="sp-snackbar full">Deleted<button>Undo</button></div>' },
      { label: 'Live', html: '<button class="sp-chip" data-snack="Saved">Show “Saved”</button><button class="sp-chip" data-snack="Deleted" data-action="Undo">Show “Deleted · Undo”</button>' },
    ],
    code: {
      compose: "val snack = rememberPopSnackbarState()\nBox(Modifier.fillMaxSize()) {\n    // screen content…\n    PopSnackbarHost(snack)\n}\nsnack.show(\"Deleted\", actionLabel = \"Undo\") { undo() }",
      swift: "@StateObject private var snack = PopSnackbarState()\n\ncontent.popSnackbarHost(snack)\nsnack.show(\"Deleted\", actionLabel: \"Undo\") { undo() }",
      html: "import { showPopSnack } from '@sticker-pop/web/behaviors';\n\nshowPopSnack('Deleted', { actionLabel: 'Undo', onAction: undo });",
      flutter: "showPopSnack(context, 'Saved');\nshowPopSnack(context, 'Deleted', actionLabel: 'Undo', onAction: undo);",
    },
    spec: [['Fill', 'ink, radius 16'], ['Text', '15/700 white; action yellow'], ['Duration', '3 s, or 6 s with an action']],
    rules: ['Never for form errors: a floating snackbar covers the Save button.'],
  },
  {
    id: 'tour', name: 'Tour (coach marks)', group: 'Overlays and feedback', platforms: ALL,
    summary: 'The screen dims under a 72% ink scrim with a rounded cut-out around the real control, outlined 3 in yellow. A yellow tour card sits on the roomier side.',
    states: [
      { label: 'Tour card', html: '<div class="sp-tour-card sp-tilt-r full"><div class="row" style="justify-content:space-between"><div class="sp-dots"><i class="is-reached"></i><i class="is-current"></i><i></i></div><button class="sp-text-button sp-text-button--underline">Skip</button></div><div class="sp-text-sheet-title">Say it</div><div class="sp-text-body">Speak an expense like “450 for lunch”. It is read on the phone and not kept.</div><button class="sp-button">Next</button></div>' },
      { label: 'Spotlight', html: '<div class="full" style="position:relative;overflow:hidden;border-radius:18px;padding:28px;background:var(--sp-color-paper)"><div class="sp-quick-add"><button class="sp-card">Type it</button><div class="sp-spotlight"><button class="sp-card sp-fill-pink" data-snack="Say it">Say it</button></div><button class="sp-card sp-fill-mint">Scan it</button></div></div>' },
    ],
    code: {
      compose: "val tour = rememberPopTourState()\nBox(Modifier.fillMaxSize()) {\n    SayItTile(Modifier.popTourTarget(tour, \"say\"))\n    PopTourOverlay(tour)\n}\ntour.start(listOf(PopTourStep(\"say\", \"Say it\", \"Speak an expense like \\\"450 for lunch\\\".\")))",
      swift: "@StateObject private var tour = PopTourState()\n\nsayItTile.popTourTarget(\"say\")\nscreen.popTourOverlay(tour)\ntour.start([PopTourStep(target: \"say\", title: \"Say it\", message: \"Speak an expense like \\\"450 for lunch\\\".\")])",
      html: "import { showPopTour } from '@sticker-pop/web/behaviors';\n\nconst finished = await showPopTour([\n  { target: '#say-it', title: 'Say it', body: 'Speak an expense like \"450 for lunch\".' },\n]);",
      flutter: "final saySpot = GlobalKey();\n…\nfinal finished = await showPopTour(context, [\n  PopTourStep(target: saySpot, title: 'Say it', body: 'Speak an expense like \"450 for lunch\".'),\n]);",
    },
    spec: [['Scrim', 'ink at 72%'], ['Cut-out', 'radius 18, 3 yellow outline'], ['Card', 'yellow, 6/6 shadow, alternating ±1.5°, 16 from edges'], ['Dots', '10 high; 22 wide when current; pink once reached'], ['Body', '15/600 at 1.3 line height']],
  },
];
