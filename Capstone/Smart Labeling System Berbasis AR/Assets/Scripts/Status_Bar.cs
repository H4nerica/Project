using UnityEngine;
using TMPro;
using Vuforia;

public class Status_Bar : MonoBehaviour
{
    public TMP_Text statusText;
    public GameObject editingObj;
    public GameObject markerDetectedObj;

    [Header("Tracking")]
    public ObserverBehaviour imageTargetObserver; // ← assign ImageTarget

    private string scannedCode = "----";

    private float dotTimer = 0f;
    private int dotCount = 0;
    public float dotDelay = 0.5f;

    private string[] editingDots = { "Editing .", "Editing . .", "Editing . . ." };
    private string[] readyDots   = { "Ready to scan .", "Ready to scan . .", "Ready to scan . . ." };

    void Update()
    {
        dotTimer += Time.deltaTime;

        // 1️⃣ EDITING always has priority
        if (editingObj != null && editingObj.activeSelf)
        {
            Animate(editingDots);
            return; // exit so nothing else overrides
        }

        // 2️⃣ NOT TRACKED → READY
        if (imageTargetObserver != null)
        {
            var status = imageTargetObserver.TargetStatus;
            if (status.Status != Status.TRACKED || status.StatusInfo != StatusInfo.NORMAL)
            {
                Animate(readyDots);
                return;
            }
        }

        // 3️⃣ MARKER DETECTED
        if (markerDetectedObj != null && markerDetectedObj.activeSelf)
        {
            statusText.text = $"Marker Detected - {scannedCode}";
            dotCount = 0;
            dotTimer = 0f;
            return;
        }

        // 4️⃣ READY fallback
        Animate(readyDots);
    }

    void Animate(string[] dots)
    {
        if (dotTimer >= dotDelay)
        {
            dotTimer = 0f;
            dotCount = (dotCount + 1) % dots.Length;
        }
        statusText.text = dots[dotCount];
    }

    public void SetScannedCode(string code)
    {
        scannedCode = code;
    }
}
