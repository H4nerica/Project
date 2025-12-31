using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class ExpiryFillBar : MonoBehaviour
{
    [Header("UI References")]
    public Image fillImage;
    public TMP_Text percentText;

    [Header("Days Left Reference")]
    public DaysLeft daysLeft; // assign your DaysLeft script here

    [Header("Max days for percentage calculation")]
    public int maxDays = 10;  // any value >=10 will be considered 100%

    void Update()
    {
        if (daysLeft == null || daysLeft.daysNumber == null) return;

        // Read days left from TMP text
        if (!int.TryParse(daysLeft.daysNumber.text, out int remainingDays))
            remainingDays = 0;

        // Calculate fill percentage
        float fill = remainingDays <= 0 ? 0f : Mathf.Clamp01((float)remainingDays / maxDays);

        // Determine color based on remainingDays
        Color fillColor = Color.green;
        if (remainingDays <= 2) fillColor = Color.red;       // 0–2 days → red
        else if (remainingDays < 5) fillColor = Color.yellow; // 3–4 days → yellow
        else fillColor = Color.green;                        // ≥5 days → green

        // Apply to UI
        if (fillImage != null)
        {
            fillImage.fillAmount = fill;
            fillImage.color = fillColor;
        }

        // Update percentage text
        if (percentText != null)
            percentText.text = Mathf.RoundToInt(fill * 100f) + "%";
    }
}
