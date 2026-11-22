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
    id: 'banner', name: 'Banner', group: 'Overlays and feedback', platforms: ALL,
    summary: 'A message that stays in the page until it is dealt with, unlike a snackbar: a bright sticker card with an icon, an optional title, the message, and an optional action and close button. Blue for information, orange for something that needs attention, mint for good news. Never red.',
    states: [
      { label: 'Warning, with action and close', html: '<div class="sp-card sp-banner sp-banner--warning full" role="status"><span class="sp-icon" aria-hidden="true">warning</span><div class="sp-banner__body"><span class="sp-banner__title">Back up soon</span><span class="sp-text-body">Your last backup was 30 days ago.</span><button class="sp-text-button sp-text-button--underline" data-snack="Backing up…">Back up now</button></div><button class="sp-banner__close" aria-label="Dismiss" onclick="this.closest(\'.sp-banner\').remove()"><span class="sp-icon">close</span></button></div>' },
      { label: 'Info', html: '<div class="sp-card sp-banner full" role="status"><span class="sp-icon" aria-hidden="true">info</span><div class="sp-banner__body"><span class="sp-text-body">Prices update every morning at 9.</span></div></div>' },
      { label: 'Success', html: '<div class="sp-card sp-banner sp-banner--success full" role="status"><span class="sp-icon" aria-hidden="true">check_circle</span><div class="sp-banner__body"><span class="sp-text-body">All caught up: nothing needs a category.</span></div></div>' },
    ],
    code: {
      flutter: "PopBanner(\n  tone: PopBannerTone.warning,\n  title: 'Back up soon',\n  message: 'Your last backup was 30 days ago.',\n  actionLabel: 'Back up now',\n  onAction: backUp,\n  onDismiss: hide,\n)",
      compose: 'PopBanner("Your last backup was 30 days ago.", title = "Back up soon", tone = PopBannerTone.Warning, actionLabel = "Back up now", onAction = ::backUp, onDismiss = ::hide)',
      swift: 'PopBanner("Your last backup was 30 days ago.", title: "Back up soon", tone: .warning, actionLabel: "Back up now", onAction: backUp, onDismiss: hide)',
      html: '<div class="sp-card sp-banner sp-banner--warning" role="status">\n  <span class="sp-icon" aria-hidden="true">warning</span>\n  <div class="sp-banner__body">\n    <span class="sp-banner__title">Back up soon</span>\n    <span class="sp-text-body">Your last backup was 30 days ago.</span>\n    <button class="sp-text-button sp-text-button--underline">Back up now</button>\n  </div>\n  <button class="sp-banner__close" aria-label="Dismiss"><span class="sp-icon">close</span></button>\n</div>',
    },
    spec: [['Card', 'StickerCard: 2.5 outline, radius 22, 4/4 shadow; blue, orange or mint'], ['Padding', '16 left, 12 top and bottom'], ['Icon', '22 ink, 12 before the text'], ['Text', 'title 16/800, message 15/600'], ['Action', 'underlined text button'], ['Close', '20 ✕ in a 40 target']],
    rules: ['Use a banner for something that stays true until handled; a snackbar for a passing confirmation.', 'One banner per screen, at the top of the content.', 'Never red: warnings are orange, and the words carry the meaning.'],
    a11y: 'A status region, so new banners are announced. The close button is labelled "Dismiss".',
  },
  {
    id: 'empty-state', name: 'Empty and error screens', group: 'Overlays and feedback', platforms: ALL,
    summary: 'For a whole screen with nothing to show yet, or one that couldn\'t load: a big tilted sticker tile with an icon, a title, a short message and up to two actions, centred. Lilac for empty, orange for errors and offline. For a hint inside a card, use the hint card instead.',
    states: [{ label: 'Empty', html: '<div class="sp-card full"><div class="sp-empty"><div class="sp-empty__tile" aria-hidden="true"><span class="sp-icon">receipt_long</span></div><h3 class="sp-empty__title">No transactions yet</h3><p class="sp-empty__message">Add your first one with Type it, Say it or Scan it.</p><button class="sp-button" data-snack="Add opens here">Add a transaction</button></div></div>' }, { label: 'Error', html: '<div class="sp-card full"><div class="sp-empty sp-empty--error"><div class="sp-empty__tile" aria-hidden="true"><span class="sp-icon">cloud_off</span></div><h3 class="sp-empty__title">Couldn&#39;t load prices</h3><p class="sp-empty__message">Check your connection and try again. Your own data is safe on this phone.</p><button class="sp-button" data-snack="Trying again…">Try again</button><button class="sp-text-button">Not now</button></div></div>' }],
    code: {
      flutter: "PopEmptyState(\n  icon: Icons.receipt_long_rounded,\n  title: 'No transactions yet',\n  message: 'Add your first one with Type it, Say it or Scan it.',\n  actionLabel: 'Add a transaction',\n  onAction: openAdd,\n)",
      compose: 'PopEmptyState(Icons.AutoMirrored.Rounded.ReceiptLong, "No transactions yet",\n    "Add your first one with Type it, Say it or Scan it.", actionLabel = "Add a transaction", onAction = ::openAdd)',
      swift: 'PopEmptyState(systemImage: "list.bullet.rectangle", title: "No transactions yet",\n              message: "Add your first one with Type it, Say it or Scan it.",\n              actionLabel: "Add a transaction", onAction: openAdd)',
      html: '<div class="sp-empty sp-empty--error">\n  <div class="sp-empty__tile" aria-hidden="true"><span class="sp-icon">cloud_off</span></div>\n  <h2 class="sp-empty__title">Couldn&#39;t load prices</h2>\n  <p class="sp-empty__message">Check your connection and try again.</p>\n  <button class="sp-button">Try again</button>\n  <button class="sp-text-button">Not now</button>\n</div>',
    },
    spec: [['Tile', '96, radius 22, 2.5 outline, 6/6 shadow, tilted −4°; lilac (empty) or orange (error)'], ['Icon', '44 ink'], ['Title', '22/800, 24 below the tile'], ['Message', '15/600 muted, centred, 8 below'], ['Actions', 'a primary button (20 below), then an optional text button'], ['Width', 'up to 340, centred']],
    rules: ['Say what will appear and how to start, or what went wrong and what to do: never just "Error".', 'Errors are orange, never red. Reassure about the person\'s own data when it is safe.'],
    a11y: 'The title is a heading; the tile is decorative and hidden from screen readers.',
  },
  {
    id: 'loading', name: 'Loading states', group: 'Overlays and feedback', platforms: ALL,
    summary: 'Show the shape of what is coming. Skeletons are divider-coloured lines, circles and blocks with no outline, gently pulsing, laid out like the content that will replace them. A small spinner is for short waits with no layout to hint at. Under reduced motion both stand still.',
    states: [
      { label: 'Skeleton list', html: '<div class="sp-card sp-list full" role="status" aria-label="Loading"><div class="sp-skeleton-row"><span class="sp-skeleton sp-skeleton--circle"></span><span class="sp-skeleton-row__text"><span class="sp-skeleton" style="width:60%"></span><span class="sp-skeleton" style="width:80%;height:10px"></span></span><span class="sp-skeleton" style="width:56px"></span></div><div class="sp-skeleton-row"><span class="sp-skeleton sp-skeleton--circle"></span><span class="sp-skeleton-row__text"><span class="sp-skeleton" style="width:45%"></span><span class="sp-skeleton" style="width:80%;height:10px"></span></span><span class="sp-skeleton" style="width:56px"></span></div><div class="sp-skeleton-row"><span class="sp-skeleton sp-skeleton--circle"></span><span class="sp-skeleton-row__text"><span class="sp-skeleton" style="width:60%"></span><span class="sp-skeleton" style="width:80%;height:10px"></span></span><span class="sp-skeleton" style="width:56px"></span></div></div>' },
      { label: 'Spinner', html: '<div class="row" role="status"><span class="sp-spinner" aria-hidden="true"></span><span class="sp-text-body">Fetching prices…</span></div>' },
      { label: 'Block (a card or chart)', html: '<span class="sp-skeleton sp-skeleton--block full" style="height:120px" role="status" aria-label="Loading"></span>' },
    ],
    code: {
      flutter: "isLoading ? const PopSkeletonList(rows: 3) : TransactionList(items)\n\nconst PopSkeleton.line(width: 120)\nconst PopSkeleton.block(height: 120)\nconst PopSpinner()",
      compose: 'if (loading) PopSkeletonList(rows = 3) else TransactionList(items)\n\nPopSkeletonLine(width = 120.dp)\nPopSkeletonBlock(height = 120.dp)\nPopSpinner()',
      swift: 'if loading { PopSkeletonList(rows: 3) } else { TransactionList(items) }\n\nPopSkeleton.line(width: 120)\nPopSkeleton.block(height: 120)\nPopSpinner()',
      html: '<div class="sp-card sp-list" role="status" aria-label="Loading">\n  <div class="sp-skeleton-row">\n    <span class="sp-skeleton sp-skeleton--circle"></span>\n    <span class="sp-skeleton-row__text">\n      <span class="sp-skeleton" style="width:60%"></span>\n      <span class="sp-skeleton" style="width:80%;height:10px"></span>\n    </span>\n  </div>\n</div>\n\n<span class="sp-spinner" role="status" aria-label="Loading"></span>',
    },
    spec: [['Skeleton', 'divider fill, no outline; lines 14 high radius 6, circles 42, blocks radius 22'], ['Pulse', 'full to 55% and back, 900 ms each way (pulse)'], ['Spinner', '24 ring, 3 divider track, ink quarter arc, one turn per 800 ms (spin)'], ['Reduced motion', 'both stand still']],
    rules: ['Prefer skeletons shaped like the real content; use a spinner only for short waits.', 'Everything is on the phone, so most screens never need either: show one only past about 300 ms.', 'For a button that is working, use its busy label ("Saving…"), not a spinner.'],
    a11y: 'A skeleton group is announced once as "Loading" (a status region), not shape by shape; the spinner is labelled "Loading".',
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
