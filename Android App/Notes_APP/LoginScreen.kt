package com.project.pertemuan3

import android.content.Context
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.foundation.border
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalInspectionMode
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.firebase.database.FirebaseDatabase
import com.project.pertemuan3.ui.theme.Pertemuan3Theme

//import for svg here
import androidx.compose.material3.Icon
import androidx.compose.ui.res.painterResource

@Composable
fun LoginScreen(onLoginSuccess: (String) -> Unit) {
    val background = Color(0xFF2B2D30)
    val cardBlue = Color(0xFF673AB7)
    val darkText = Color.Black

    val context = LocalContext.current
    val prefs = context.getSharedPreferences("login_prefs", Context.MODE_PRIVATE)

    var email by remember {
        mutableStateOf(prefs.getString("saved_email", "") ?: "")
    }
    var password by remember { mutableStateOf("") }
    var errorText by remember { mutableStateOf("") }

    val dbRef = if (!LocalInspectionMode.current) {
        FirebaseDatabase
            .getInstance("https://pertemuan3-3fd24-default-rtdb.asia-southeast1.firebasedatabase.app")
            .getReference("credentials")
    } else null

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White),
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth(0.8f)
                .background(Color.Transparent, RoundedCornerShape(12.dp))
                .padding(24.dp)
        ) {
            Icon(
                painter = painterResource(id = R.drawable.account_icon), // your SVG in res/drawable
                contentDescription = "Logo",
                modifier = Modifier
                    .size(120.dp)
                    .align(Alignment.CenterHorizontally)
            )

            //spasi here to make it good
            Spacer(modifier = Modifier.height(50.dp))

            Text(
                text = "Sign In",
                color = Color.Black,
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier
                    .align(Alignment.Start)
                    .padding(bottom = 2.dp)
            )
            Text(
                text = "PLease Sign In To Continue",
                color = Color.Black,
                fontSize = 14.sp,
                modifier = Modifier
                    .align(Alignment.Start)
                    .padding(bottom = 24.dp)
            )

            Spacer(modifier = Modifier.height(10.dp))

            Text(text = "Email", color = darkText, fontSize = 16.sp)
            Spacer(modifier = Modifier.height(8.dp))


            //email form here
            BasicTextField(
                value = email,
                onValueChange = {
                    email = it
                    errorText = ""
                },
                singleLine = true,
                textStyle = TextStyle(color = Color.Black, fontSize = 14.sp),
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.Transparent)
                    .border(
                        width = 0.8.dp,
                        color = darkText,
                        shape = RoundedCornerShape(6.dp)
                    )
                    .padding(12.dp),
                decorationBox = { innerTextField ->
                    Box {
                        if (email.isEmpty()) {
                            Text(
                                text = "Email",
                                color = Color.Gray,
                                fontSize = 14.sp
                            )
                        }
                        innerTextField()
                    }
                }
            )


            Spacer(modifier = Modifier.height(20.dp))

            Text(text = "Password", color = darkText, fontSize = 16.sp)
            Spacer(modifier = Modifier.height(8.dp))

            var displayPassword by remember { mutableStateOf("") }

            BasicTextField(
                value = displayPassword,
                onValueChange = { newText ->
                    // Update actual password directly
                    if (newText.length > displayPassword.length) {
                        // New char typed
                        val newChar = newText.last()
                        password += newChar
                    } else if (newText.length < displayPassword.length) {
                        // Backspace
                        password = password.dropLast(displayPassword.length - newText.length)
                    }

                    // Update UI display only
                    displayPassword = if (password.isEmpty()) ""
                    else "*".repeat(password.length - 1) + password.last()

                    errorText = ""
                },
                singleLine = true,
                textStyle = TextStyle(color = Color.Black, fontSize = 14.sp),
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.Transparent)
                    .border(0.8.dp, darkText, RoundedCornerShape(6.dp))
                    .padding(12.dp),
                decorationBox = { innerTextField ->
                    Box {
                        if (displayPassword.isEmpty()) {
                            Text("Password", color = Color.Gray, fontSize = 14.sp)
                        }
                        innerTextField()
                    }
                }
            )


            Spacer(modifier = Modifier.height(16.dp))

            if (errorText.isNotEmpty()) {
                Text(
                    text = errorText,
                    color = Color.Red,
                    fontSize = 12.sp
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            Button(
                onClick = {
                    if (!email.contains("@")) {
                        errorText = "Invalid email"
                        return@Button
                    }
                    if (password.trim().length < 8) {
                        errorText = "Password must be at least 8 characters"
                        return@Button
                    }

                    dbRef?.get()?.addOnSuccessListener { snapshot ->
                        var found = false
                        for (child in snapshot.children) {
                            val storedEmail = child.child("email").getValue(String::class.java)
                            val storedPassword = child.child("password").getValue(String::class.java)
                            if (storedEmail == email && storedPassword == password) {
                                found = true
                                break
                            }
                        }

                        if (found) {
                            prefs.edit()
                                .putString("saved_email", email)
                                .apply()

                            errorText = ""
                            onLoginSuccess(email)
                        } else {
                            errorText = "No user found with this email/password"
                        }
                    }?.addOnFailureListener {
                        errorText = "Failed to check credentials"
                    }
                },
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF0056FF),
                    contentColor = Color.White
                ),
                shape = RoundedCornerShape(24.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp)
            ) {
                Text(
                    text = "Login",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
fun PreviewLoginScreen() {
    Pertemuan3Theme {
        LoginScreen(onLoginSuccess = {})
    }
}
