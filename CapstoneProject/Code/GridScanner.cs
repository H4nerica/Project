using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class GridScanner : MonoBehaviour
{
    [Header("UI & Camera")]
    public RectTransform scanArea; // Scan rectangle in the middle (assign in Canvas)
    public Camera arCamera;        // AR Camera
    public TextMeshProUGUI panelText; // Text inside the Image Target panel
    public Button scanButton;      // UI Button to trigger scan

    public ItemInfoManager infoManager; // Reference to your ItemInfoManager
    public EditFormController formController; // Reference to your EditFormController

    [Header("Detection Settings")]
    [Range(0f, 1f)]
    public float blackPixelThreshold = 0.3f;      // brightness < 0.3 = black
    [Range(0f, 1f)]
    public float blackPixelRatioThreshold = 0.3f; // % of black pixels to count as 1

    private bool hasScanned = false; // track first scan

    void Start()
    {
        if (scanButton != null)
            scanButton.onClick.AddListener(OnScanButtonPressed);
        else
            Debug.LogWarning("[GridScanner] Scan button not assigned!");

        // Show hint initially (if available)
        if (infoManager != null && infoManager.TMPHint != null)
            infoManager.TMPHint.gameObject.SetActive(true);
    }

    public void OnScanButtonPressed()
    {
        string code = ScanGrid();
        Debug.Log($"[GridScanner] Detected binary: {code}");
        CurrentMarkerID.currentID = code;

        // Hide hint after first scan
        if (!hasScanned)
        {
            hasScanned = true;
            if (infoManager != null && infoManager.TMPHint != null)
                infoManager.TMPHint.gameObject.SetActive(false);
        }

        if (panelText != null)
            panelText.text = code;

        // Show panel info
        if (infoManager != null)
        {
            infoManager.ShowItemInfo(code);
        }
        else
        {
            Debug.LogWarning("[GridScanner] InfoManager not assigned!");
        }

        // Populate the EditForm fields
        if (formController != null)
            formController.PopulateFormFields(code);
        else
            Debug.LogWarning("[GridScanner] FormController not assigned!");
    }

    string ScanGrid()
    {
        // Hide scan area to avoid overlay interference
        bool wasActive = scanArea.gameObject.activeSelf;
        scanArea.gameObject.SetActive(false);

        // Convert scan area to screen coordinates
        Vector2 screenPos = scanArea.position;
        Vector2 size = scanArea.rect.size;
        float scaleFactor = scanArea.GetComponentInParent<Canvas>().scaleFactor;

        int width = Mathf.RoundToInt(size.x * scaleFactor);
        int height = Mathf.RoundToInt(size.y * scaleFactor);

        int x = Mathf.RoundToInt((screenPos.x - size.x / 2f) * scaleFactor);
        int y = Mathf.RoundToInt((screenPos.y - size.y / 2f) * scaleFactor);

        x = Mathf.Clamp(x, 0, Screen.width - width);
        y = Mathf.Clamp(y, 0, Screen.height - height);

        // Capture camera feed
        RenderTexture rt = new RenderTexture(Screen.width, Screen.height, 24);
        arCamera.targetTexture = rt;
        arCamera.Render();
        RenderTexture.active = rt;

        Texture2D tex = new Texture2D(width, height, TextureFormat.RGB24, false);
        tex.ReadPixels(new Rect(x, y, width, height), 0, 0);
        tex.Apply();

        // Cleanup
        arCamera.targetTexture = null;
        RenderTexture.active = null;
        Destroy(rt);

        scanArea.gameObject.SetActive(wasActive);

        // Divide into 4 horizontal segments (binary code)
        int segments = 4;
        string binary = "";

        for (int i = 0; i < segments; i++)
        {
            int startX = i * width / segments + width / (segments * 4);
            int endX = (i + 1) * width / segments - width / (segments * 4);
            int startY = height / 4;
            int endY = 3 * height / 4;

            int blackCount = 0;
            int totalCount = 0;

            for (int px = startX; px < endX; px++)
            {
                for (int py = startY; py < endY; py++)
                {
                    Color pixel = tex.GetPixel(px, py);
                    float brightness = (pixel.r + pixel.g + pixel.b) / 3f;
                    if (brightness < blackPixelThreshold)
                        blackCount++;
                    totalCount++;
                }
            }

            float blackRatio = (float)blackCount / totalCount;
            binary += (blackRatio >= blackPixelRatioThreshold) ? "1" : "0";
        }

        Destroy(tex);
        return binary;
    }
}
