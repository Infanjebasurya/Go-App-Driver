package com.sybrox.goapp_captain.platform.services

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.provider.ContactsContract
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ContactsService(private val activity: Activity) : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getContacts" -> {
                if (
                    ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_CONTACTS) !=
                    PackageManager.PERMISSION_GRANTED
                ) {
                    result.error("permission_denied", "READ_CONTACTS not granted", null)
                    return
                }

                try {
                    result.success(loadContacts())
                } catch (e: Exception) {
                    result.error("contacts_error", e.message, null)
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun loadContacts(): List<Map<String, Any?>> {
        val resolver = activity.contentResolver
        val projection = arrayOf(
            ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
            ContactsContract.CommonDataKinds.Phone.NUMBER
        )

        val cursor = resolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            projection,
            null,
            null,
            "${ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME} ASC"
        ) ?: return emptyList()

        val byId = LinkedHashMap<String, ContactAcc>()
        cursor.use {
            val idIdx = cursor.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.CONTACT_ID)
            val nameIdx = cursor.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
            val numIdx = cursor.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.NUMBER)

            while (cursor.moveToNext()) {
                val id = cursor.getString(idIdx) ?: continue
                val name = cursor.getString(nameIdx) ?: ""
                val number = cursor.getString(numIdx) ?: ""
                val acc = byId.getOrPut(id) { ContactAcc(id = id, displayName = name) }
                if (number.isNotBlank()) {
                    acc.phones.add(number)
                }
            }
        }

        return byId.values.map { acc ->
            mapOf(
                "id" to acc.id,
                "displayName" to acc.displayName,
                "phones" to acc.phones.distinct().map { n -> mapOf("number" to n) }
            )
        }
    }

    private data class ContactAcc(
        val id: String,
        val displayName: String,
        val phones: MutableList<String> = mutableListOf()
    )
}

