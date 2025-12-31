using UnityEngine;
using TMPro;
using System;
using System.Globalization;

public class DaysLeft : MonoBehaviour
{
    [Header("TMP Reference")]
    public TMP_Text daysNumber;   // Assign the TMP number in inspector

    private string expiryDateString;

    /// <summary>
    /// Call this from ItemInfoManager to set the expiry and update the number.
    /// </summary>
    public void SetExpiry(string expiry)
    {
        if (string.IsNullOrEmpty(expiry))
        {
            // Clear old value to prevent stale days
            expiryDateString = null;
            daysNumber.text = "0";
            return;
        }

        expiryDateString = expiry;
        UpdateDaysLeft();
    }

    /// <summary>
    /// Calculates remaining days and updates the TMP text.
    /// Fully safe: returns 0 if expiry is invalid or empty.
    /// </summary>
    public void UpdateDaysLeft()
    {
        if (string.IsNullOrEmpty(expiryDateString))
        {
            daysNumber.text = "0";
            return;
        }

        DateTime expiryDate;
        bool valid = DateTime.TryParseExact(
            expiryDateString,
            "dd-MM-yyyy",                 // Adjust if your JSON uses another format
            CultureInfo.InvariantCulture,
            DateTimeStyles.None,
            out expiryDate
        );

        if (!valid)
        {
            Debug.LogWarning($"Invalid expiry date format: {expiryDateString}");
            daysNumber.text = "0";
            return;
        }

        DateTime today = DateTime.Now.Date;
        int daysLeft = (expiryDate - today).Days;
        if (daysLeft < 0) daysLeft = 0;

        daysNumber.text = daysLeft.ToString();
    }
}
