using UnityEngine;
using TMPro;
using Unity.VectorGraphics; // for SVGImage

public class ExpiryStatus : MonoBehaviour
{
    [Header("References")]
    public DaysLeft daysLeftScript;  // drag your DaysLeft script
    public TMP_Text statusText;      // main text
    public TMP_Text secondaryText;   // secondary text (only color changes)
    public SVGImage svgImage;        // SVG component

    private int lastDays = -1;

    void Update()
    {
        if (daysLeftScript == null || daysLeftScript.daysNumber == null || svgImage == null)
            return;

        if (int.TryParse(daysLeftScript.daysNumber.text, out int currentDays))
        {
            if (currentDays != lastDays)
            {
                UpdateStatus(currentDays);
                lastDays = currentDays;
            }
        }
    }

    private void UpdateStatus(int daysLeft)
    {
        Color color;
        string text;

        if (daysLeft <= 0)
        {
            color = Color.red;
            text = "Expired";
        }
        else if (daysLeft <= 2)
        {
            color = Color.yellow;
            text = "Caution";
        }
        else
        {
            color = Color.green;
            text = "Fresh";
        }

        // update main text fully
        if (statusText != null)
        {
            statusText.text = text;
            statusText.color = color;
        }

        // only change color of secondary text
        if (secondaryText != null)
        {
            secondaryText.color = color;
        }

        // update svg color
        svgImage.color = color;
    }
}
