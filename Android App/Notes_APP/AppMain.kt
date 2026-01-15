package com.project.pertemuan3

import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Base64
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.text.TextRange
import androidx.compose.foundation.layout.Row
import androidx.compose.ui.res.painterResource
import com.google.firebase.database.FirebaseDatabase
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.ui.graphics.Brush

// ---------------- DATA ----------------
data class Note(
    val id: String = "",
    val header: String = "",
    val content: String = "",
    val textAlignValue: String = "Start" // store as string
) {
    val textAlign: TextAlign
        get() = when(textAlignValue) {
            "Start" -> TextAlign.Start
            "Center" -> TextAlign.Center
            "End" -> TextAlign.End
            else -> TextAlign.Start
        }
}

//styleing
val background = Color(0xFF1e1f22)
val searchBG = Color(0xFF2b2d30)
val headerBG = Color(0xFF2b2d30)
val headerBG2 = Brush.horizontalGradient(
    colors = listOf(Color(0xFF0084FF), Color(0xFF673AB7))
)
val headertxt = Color(0xFFFFFFFF)
val contenttxt = Color(0xFFFFFFFF)
val profileBG = Color(0xFF2b2d30)
val normaltxt = Color(0xFFFFFFFF)

// ---------------- MAIN ----------------
@Composable
fun AppMain(currentUserEmail: String) {
    val context = LocalContext.current
    val userKey = currentUserEmail.replace(".", "_")

    val notesRef = FirebaseDatabase
        .getInstance("https://pertemuan3-3fd24-default-rtdb.asia-southeast1.firebasedatabase.app")
        .getReference("user_notes")
        .child(userKey)

    val profileRef = FirebaseDatabase
        .getInstance("https://pertemuan3-3fd24-default-rtdb.asia-southeast1.firebasedatabase.app")
        .getReference("user_profiles")
        .child(userKey)

    var notes by remember { mutableStateOf(listOf<Note>()) }
    var searchText by remember { mutableStateOf("") }
    var showForm by remember { mutableStateOf(false) }
    var editingNote by remember { mutableStateOf<Note?>(null) }
    var showProfile by remember { mutableStateOf(false) }
    var profileImageBase64 by remember { mutableStateOf<String?>(null) }

    // Load notes and profile image once
    LaunchedEffect(Unit) {
        notesRef.get().addOnSuccessListener { snapshot ->
            notes = snapshot.children.mapNotNull {
                it.getValue(Note::class.java)?.copy(id = it.key ?: "")
            }
        }
        profileRef.child("imageBase64").get().addOnSuccessListener {
            profileImageBase64 = it.getValue(String::class.java)
        }

    }

    // Launcher to pick image
    val galleryLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let {
            uploadProfileImageToDatabase(it, context, profileRef) { base64 ->
                profileImageBase64 = base64
            }
        }
    }

    // ---- BACKGROUND + TOP BAR ----
    Box(modifier = Modifier.fillMaxSize().background(background)) {
        // Top gradient bar (always visible)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(64.dp)
                .background(
                    brush = Brush.horizontalGradient(
                        colors = listOf(Color(0xFF0084FF), Color(0xFF673AB7))
                    )
                )
                .align(Alignment.TopStart)
        )

        // ---- Profile pic----
        if (!showForm && !showProfile) {
            HomeContent(
                notes = notes,
                searchText = searchText,
                onSearchChange = { searchText = it },
                onNoteClick = { note ->
                    editingNote = note
                    showForm = true
                },
                profileImageBase64 = profileImageBase64,
                onProfileClick = { showProfile = true }
            )
        } else if (showForm) {
            EditNoteForm(
                note = editingNote,
                onSave = { note ->
                    val id = note.id.ifEmpty { notesRef.push().key ?: "" }
                    notesRef.child(id).setValue(note.copy(id = id))
                    notes = notes.filter { it.id != id } + note.copy(id = id)
                    showForm = false
                },
                onDelete = { noteToDelete ->
                    notesRef.child(noteToDelete.id).removeValue()
                    notes = notes.filter { it.id != noteToDelete.id }
                    showForm = false
                },
                onCancel = { showForm = false }
            )
        } else if (showProfile) {
            ProfileOverlay(
                email = currentUserEmail,
                profileImageBase64 = profileImageBase64,
                onClose = { showProfile = false },
                onImagePick = { galleryLauncher.launch("image/*") }
            )
        }
    }
}

// ---------------- HOME CONTENT ----------------
@Composable
fun HomeContent(
    notes: List<Note>,
    searchText: String,
    onSearchChange: (String) -> Unit,
    onNoteClick: (Note) -> Unit,
    profileImageBase64: String?,
    onProfileClick: () -> Unit
) {
    Box(modifier = Modifier.fillMaxSize()) { // Parent Box for proper FAB alignment

        Column(modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 16.dp)
        ) {
            Spacer(Modifier.height(8.dp))

            // Profile button
            Box(modifier = Modifier.fillMaxWidth()) {
                IconButton(
                    onClick = onProfileClick,
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .size(48.dp)
                        .clip(RoundedCornerShape(24.dp))
                        .background(Color.Gray)
                ) {
                    if (profileImageBase64 != null) {
                        val bitmap = loadBitmapFromBase64(profileImageBase64!!)
                        bitmap?.let {
                            Image(
                                bitmap = it.asImageBitmap(),
                                contentDescription = "Profile",
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxSize()
                            )
                        } ?: Text("U", color = Color.White, fontWeight = FontWeight.Bold)
                    } else {
                        Text("U", color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }
            }

            Spacer(Modifier.height(40.dp))

            // SEARCH BOX
            Text(
                text = "Search",
                fontSize = 18.sp,
                color = Color.White,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 4.dp)
            )
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(searchBG, RoundedCornerShape(6.dp))
                    .padding(horizontal = 12.dp, vertical = 8.dp)
            ) {
                if (searchText.isEmpty()) {
                    Text("Search keyword", color = Color.Gray, fontSize = 18.sp)
                }

                BasicTextField(
                    value = searchText,
                    onValueChange = onSearchChange,
                    textStyle = TextStyle(fontSize = 18.sp, color = Color.White),
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true
                )
            }

            Spacer(Modifier.height(14.dp))

            val filtered = notes.filter {
                it.header.contains(searchText, true) || it.content.contains(searchText, true)
            }

            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                contentPadding = PaddingValues(bottom = 80.dp),
                modifier = Modifier.weight(1f) // takes remaining vertical space
            ) {
                items(filtered) { note ->
                    NoteCard(note) { onNoteClick(note) }
                }
            }
        }

        // "+" button overlayed at bottom-end
        // "+" button overlayed at bottom-end
        Box(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(16.dp)
                .size(48.dp)
                .background(
                    brush = Brush.horizontalGradient(
                        colors = listOf(Color(0xFF0084FF), Color(0xFF673AB7))
                    ),
                    shape = RoundedCornerShape(12.dp)
                )
                .clickable(  // <- replace FAB with Box clickable
                    interactionSource = remember { MutableInteractionSource() }, // <- needed to remove ripple
                    indication = null // <- disables ripple
                ) {
                    onNoteClick(Note())
                },
            contentAlignment = Alignment.Center
        ) {
            Icon(
                painter = painterResource(R.drawable.tab),
                contentDescription = "Add Note",
                tint = Color.White,
                modifier = Modifier.size(28.dp)
            )
        }

    }
}


// ---------------- PROFILE OVERLAY ----------------
@Composable
fun ProfileOverlay(
    email: String,
    profileImageBase64: String?,
    onClose: () -> Unit,
    onImagePick: () -> Unit
) {
    BackHandler { onClose() }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(profileBG)
            .clickable(
                onClick = { /* consume */ },
                indication = null,
                interactionSource = remember { MutableInteractionSource() }
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 40.dp), // distance from top
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(120.dp)
                    .clip(RoundedCornerShape(60.dp))
                    .background(Color.Gray)
                    .clickable { onImagePick() },
                contentAlignment = Alignment.Center
            ) {
                if (profileImageBase64 != null) {
                    val bitmap = loadBitmapFromBase64(profileImageBase64!!)
                    bitmap?.let {
                        Image(
                            bitmap = it.asImageBitmap(),
                            contentDescription = "Profile",
                            contentScale = ContentScale.Crop,
                            modifier = Modifier.fillMaxSize()
                        )
                    } ?: Text("U", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 32.sp)
                } else {
                    Text("U", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 32.sp)
                }
            }

            Spacer(Modifier.height(16.dp))
//-------------current user name here---------------
            Text(
                text = "Email : " + email,
                fontSize = 20.sp,
                fontWeight = FontWeight.Bold,
                color = normaltxt,
            )
        }
    }
}


// ---------------- UPLOAD IMAGE AS BASE64 ----------------
private fun uploadProfileImageToDatabase(
    uri: Uri,
    context: android.content.Context,
    profileRef: com.google.firebase.database.DatabaseReference,
    onComplete: (String) -> Unit
) {
    val inputStream = context.contentResolver.openInputStream(uri)
    val bytes = inputStream?.readBytes()
    inputStream?.close()
    if (bytes != null) {
        val base64 = Base64.encodeToString(bytes, Base64.DEFAULT)
        profileRef.child("imageBase64").setValue(base64)
        onComplete(base64)
    }
}

// ---------------- LOAD BITMAP FROM BASE64 ----------------
@Composable
fun loadBitmapFromBase64(base64: String): android.graphics.Bitmap? {
    var bitmap by remember { mutableStateOf<android.graphics.Bitmap?>(null) }
    LaunchedEffect(base64) {
        try {
            val bytes = Base64.decode(base64, Base64.DEFAULT)
            bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
        } catch (_: Exception) {
            bitmap = null
        }
    }
    return bitmap
}

// ---------------- NOTE CARD ----------------
@Composable
fun NoteCard(note: Note, onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color.Transparent),
        //shadow or stroke
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
    ) {
        Column {
//----------------HEader card--------------------
            // ---- Blue thing ----
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(headerBG2)
                    .height(16.dp),
            )

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        color = headerBG,
                        shape = RoundedCornerShape(bottomStart = 12.dp, bottomEnd = 12.dp)
                    )
                    .padding(12.dp)
            ) {
                Column {

                    Text(
                        text = if (note.header.isBlank()) "No title" else note.header,
                        color = headertxt,
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = note.content,
                        color = Color.White,
                        fontSize = 10.sp,
                        maxLines = 4,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }

        }
    }
}

// ---------------- EDIT NOTE FORM ----------------
@Composable
fun EditNoteForm(note: Note?, onSave: (Note) -> Unit, onCancel: () -> Unit, onDelete: (Note) -> Unit) {
    var headerText by remember { mutableStateOf(note?.header ?: "") }
    var contentText by remember { mutableStateOf(TextFieldValue(note?.content ?: "")) }
    var textAlign by remember { mutableStateOf(note?.textAlign ?: TextAlign.Start) } // load from Note

    // Toolbar state
    var useNumberList by remember { mutableStateOf(false) }
    var numberCounter by remember { mutableStateOf(1) }
    val bulletChar = "• "

    LaunchedEffect(note) {
        numberCounter = 1
        useNumberList = false

        note?.content?.lines()?.lastOrNull()?.let { lastLine ->
            val numberMatch = Regex("(\\d+)\\.\\s.*").find(lastLine)
            val bulletMatch = lastLine.startsWith("• ")

            when {
                numberMatch != null -> {
                    useNumberList = true
                    numberCounter = numberMatch.groupValues[1].toInt() + 1
                }
                bulletMatch -> {
                    useNumberList = false
                    numberCounter = 1
                }
            }
        }
    }



    fun insertListItem() {
        val prefix = if (useNumberList) "${numberCounter}. " else bulletChar
        contentText = buildString {
            if (contentText.text.isEmpty()) {
                append(prefix)
            } else {
                append(contentText.text)
                if (!contentText.text.endsWith("\n")) append("\n")
                append(prefix)
            }
        }.let { TextFieldValue(it, TextRange(it.length)) }
        if (useNumberList) numberCounter++
    }

    Column(modifier = Modifier
        .fillMaxSize()
        .background(background)
        .imePadding() // ← automatically moves content above keyboard
    ){

        // Top toolbar
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    brush = Brush.horizontalGradient(
                        colors = listOf(Color(0xFF0084FF), Color(0xFF673AB7))
                    )
                )
                .padding(12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // CANCEL - Yellow
                Box(
                    modifier = Modifier
                        .size(16.dp)
                        .clip(RoundedCornerShape(50))
                        .background(Color(0xFFFFC107)) // yellow
                        .clickable { onCancel() }
                )

                Spacer(modifier = Modifier.width(8.dp))

                // DELETE - Red
                Box(
                    modifier = Modifier
                        .size(16.dp)
                        .clip(RoundedCornerShape(50))
                        .background(Color(0xFFE53935)) // red
                        .clickable { note?.let { onDelete(it) } }
                )

                Spacer(modifier = Modifier.width(8.dp))

                // SAVE - Green
                Box(
                    modifier = Modifier
                        .size(16.dp)
                        .clip(RoundedCornerShape(50))
                        .background(Color(0xFF4CAF50)) // green
                        .clickable {
                            onSave(
                                Note(
                                    id = note?.id ?: "",
                                    header = headerText,
                                    content = contentText.text,
                                    textAlignValue = when (textAlign) {
                                        TextAlign.Start -> "Start"
                                        TextAlign.Center -> "Center"
                                        TextAlign.End -> "End"
                                        else -> "Start"
                                    }
                                )
                            )
                        }
                )
            }
        }


        Spacer(modifier = Modifier.height(8.dp))

        // HEADER
        TextField(
            value = headerText,
            onValueChange = { headerText = it },
            textStyle = LocalTextStyle.current.copy(fontWeight = FontWeight.Bold, fontSize = 20.sp, color = contenttxt),
            placeholder = { Text("Title", fontWeight = FontWeight.Bold, fontSize = 20.sp, color = Color.White) },
            colors = TextFieldDefaults.colors(
                focusedContainerColor = Color.Transparent,
                unfocusedContainerColor = Color.Transparent,
                focusedIndicatorColor = Color.Transparent,
                unfocusedIndicatorColor = Color.Transparent
            ),
            modifier = Modifier
                .fillMaxWidth()
                .padding(10.dp)
        )

        // CONTENT
        TextField(
            value = contentText,
            onValueChange = { newValue ->
                val oldText = contentText.text
                var cursorPos = newValue.selection.start.coerceIn(0, newValue.text.length)

                // Handle empty text safely
                if (newValue.text.isEmpty()) {
                    contentText = newValue
                    numberCounter = 1
                    return@TextField
                }

                // Check if Enter was pressed
                val justPressedEnter = newValue.text.length > oldText.length &&
                        newValue.text.getOrNull(cursorPos - 1) == '\n'

                if (justPressedEnter) {
                    // If oldText is empty, just return
                    if (oldText.isEmpty()) return@TextField

                    // safe lineStart
                    val safeIndex = (cursorPos - 2).coerceAtLeast(0)
                    val lineStart = oldText.lastIndexOf('\n', safeIndex).let { if (it == -1) 0 else it + 1 }
                    val lineEndRaw = oldText.indexOf('\n', safeIndex)
                    val lineEnd = if (lineEndRaw == -1) oldText.length else lineEndRaw

                    // ensure start <= end
                    if (lineStart > lineEnd) {
                        contentText = newValue
                        return@TextField
                    }

                    val currentLine = oldText.substring(lineStart, lineEnd)

                    if (currentLine.isBlank()) {
                        // Empty line — no list prefix inserted
                        contentText = newValue
                        if (useNumberList) numberCounter++  // optionally increment counter
                        return@TextField
                    }

                    val numberMatch = Regex("^(\\d+)\\.\\s").find(currentLine)
                    val bulletMatch = currentLine.startsWith("• ")

                    val insertText = when {
                        numberMatch != null -> "${numberMatch.groupValues[1].toInt() + 1}. "
                        bulletMatch -> "• "
                        else -> null
                    }

                    if (insertText != null) {
                        val safeCursor = cursorPos.coerceIn(0, newValue.text.length)
                        val textBeforeCursor = newValue.text.substring(0, safeCursor)
                        val textAfterCursor = newValue.text.substring(safeCursor)
                        val updatedText = textBeforeCursor + insertText + textAfterCursor
                        val safeSelection = (safeCursor + insertText.length).coerceIn(0, updatedText.length)
                        contentText = TextFieldValue(updatedText, TextRange(safeSelection))
                        if (numberMatch != null) numberCounter = numberMatch.groupValues[1].toInt() + 2
                        return@TextField
                    }
                }

                // Normal typing fallback
                contentText = newValue
            },
            textStyle = LocalTextStyle.current.copy(textAlign = textAlign, fontWeight = FontWeight.Bold, fontSize = 12.sp, color = contenttxt),
            placeholder = { Text("Write something...", color = Color.White) },
            colors = TextFieldDefaults.colors(
                focusedContainerColor = Color.Transparent,
                unfocusedContainerColor = Color.Transparent,
                focusedIndicatorColor = Color.Transparent,
                unfocusedIndicatorColor = Color.Transparent
            ),
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
        )



        // ALIGN / LIST TOOLBAR
        EditToolbar(
            onAlignLeft = { textAlign = TextAlign.Start },
            onAlignCenter = { textAlign = TextAlign.Center },
            onAlignRight = { textAlign = TextAlign.End },
            onNumberList = {
                useNumberList = true
                numberCounter = 1   // ← RESET HERE
                insertListItem()
            },
            onBullet = { useNumberList = false; insertListItem() }
        )

        Spacer(modifier = Modifier.height(8.dp))
    }
}

// ---------------- TOOLBAR ----------------
@Composable
fun EditToolbar(
    onAlignLeft: () -> Unit = {},
    onAlignCenter: () -> Unit = {},
    onAlignRight: () -> Unit = {},
    onNumberList: () -> Unit = {},
    onBullet: () -> Unit = {}
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.Transparent)
            .padding(4.dp),
        horizontalArrangement = Arrangement.SpaceEvenly
    ) {
        IconButton(onClick = onAlignLeft) {
            Icon(painter = painterResource(R.drawable.align_left), contentDescription = "Align Left", tint = Color.White, modifier = Modifier.size(20.dp))
        }
        IconButton(onClick = onAlignCenter) {
            Icon(painter = painterResource(R.drawable.align_center), contentDescription = "Align Center", tint = Color.White, modifier = Modifier.size(20.dp))
        }
        IconButton(onClick = onAlignRight) {
            Icon(painter = painterResource(R.drawable.align_right), contentDescription = "Align Right", tint = Color.White, modifier = Modifier.size(20.dp))
        }
        IconButton(onClick = onNumberList) {
            Icon(painter = painterResource(R.drawable.number_list), contentDescription = "Numbered List", tint = Color.White, modifier = Modifier.size(20.dp))
        }
        IconButton(onClick = onBullet) {
            Icon(painter = painterResource(R.drawable.bullet_list), contentDescription = "Bullet List", tint = Color.White, modifier = Modifier.size(24.dp))
        }
    }
}

// ---------------- PREVIEW ----------------
/*@Preview(showBackground = true)
@Composable
fun PreviewEditForm() {
    EditNoteForm(note = Note("1", "Header", "Content"), onSave = {}, onCancel = {}, onDelete = {})
}*/

@Preview(showSystemUi = true)
@Composable
fun HomePreview() {
    val dummyNotes = listOf(
        Note("1", "Shopping List", "Milk\nEggs\nBread\nCoffee"),
        Note("2", "Todo", "Finish UI\nFix bugs\nPush to GitHub")
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(background)
    ) {

        // Top gradient bar
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(64.dp)
                .background(
                    Brush.horizontalGradient(
                        listOf(Color(0xFF0084FF), Color(0xFF673AB7))
                    )
                )
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp)
        ) {
            Spacer(Modifier.height(80.dp))

            // ---- SEARCH (preview-only) ----
            Text(
                text = "Search",
                fontSize = 18.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 4.dp)
            )

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        color = headerBG,
                        shape = RoundedCornerShape(6.dp)
                    )
                    .padding(horizontal = 12.dp, vertical = 8.dp)
            ) {
                Text(
                    text = "Search notes...",
                    color = Color.White,
                    fontSize = 18.sp
                )
            }

            Spacer(Modifier.height(14.dp))

            // ---- NOTES GRID ----
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                contentPadding = PaddingValues(bottom = 16.dp),
                modifier = Modifier
                    .weight(1f)
                    .background(background)
            ) {
                items(dummyNotes) { note ->
                    NoteCard(note = note, onClick = {})
                }
            }
        }
    }
}
/*@Preview(showSystemUi = true)
@Composable
fun ProfilePreview() {
    ProfileOverlay(
        email = "user@example.com",
        profileImageBase64 = null, // put Base64 string here to preview image
        onClose = {},
        onImagePick = {}
    )
}*/


