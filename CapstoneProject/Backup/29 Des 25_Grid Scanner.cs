using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class GridScanner_Auto : MonoBehaviour
{
    [Header("World Scan Box & Camera")]
    public RectTransform scanArea;
    public Camera arCamera;
    public TextMeshProUGUI panelText;

    [Header("Managers")]
    public ItemInfoManager infoManager;
    public EditFormController formController;

    [Header("UI")]
    public Status_Bar statusBar; // drag your Status_Bar object here in the inspector


    [Header("Detection Settings")]
    [Range(0f, 1f)] public float blackPixelThreshold = 0.3f;
    [Range(0f, 1f)] public float blackPixelRatioThreshold = 0.3f;
    [Range(0.1f, 5f)] public float scanInterval = 1f;

    private float scanTimer = 0f;

    void Start()
    {
        // Show hint initially
        if (infoManager != null && infoManager.TMPHint != null)
            infoManager.TMPHint.gameObject.SetActive(true);
    }

void Update()
{
    // If the overlay_edit panel is active, don’t scan
    if (formController != null && formController.gameObject.activeSelf)
        return;

    scanTimer += Time.deltaTime;
    if (scanTimer >= scanInterval)
    {
        scanTimer = 0f;
        OnScanButtonPressed();
    }
}


    public void OnScanButtonPressed()
    {
        string code = ScanGrid();
        Debug.Log($"[GridScanner] Detected binary: {code}");
        CurrentMarkerID.currentID = code;

        //status bar here
        if (statusBar != null)
        statusBar.SetScannedCode(code);

        // Hide hint if still active
        if (infoManager != null && infoManager.TMPHint != null && infoManager.TMPHint.gameObject.activeSelf)
            infoManager.TMPHint.gameObject.SetActive(false);

        // Update panel
        if (panelText != null)
            panelText.text = code;

        // Show item info
        if (infoManager != null)
            infoManager.ShowItemInfo(code);

        // Populate edit form
        if (formController != null)
            formController.PopulateFormFields(code);
    }

    string ScanGrid()
    {
        if (scanArea == null || arCamera == null)
        {
            Debug.LogWarning("[GridScanner] Missing scanArea or arCamera!");
            return "----";
        }

        Vector3[] corners = new Vector3[4];
        scanArea.GetWorldCorners(corners);
        Vector2 bottomLeft = RectTransformUtility.WorldToScreenPoint(arCamera, corners[0]);
        Vector2 topRight = RectTransformUtility.WorldToScreenPoint(arCamera, corners[2]);

        int x = Mathf.RoundToInt(bottomLeft.x);
        int y = Mathf.RoundToInt(bottomLeft.y);
        int width = Mathf.RoundToInt(topRight.x - bottomLeft.x);
        int height = Mathf.RoundToInt(topRight.y - bottomLeft.y);

        x = Mathf.Clamp(x, 0, Screen.width - 1);
        y = Mathf.Clamp(y, 0, Screen.height - 1);
        width = Mathf.Clamp(width, 1, Screen.width - x);
        height = Mathf.Clamp(height, 1, Screen.height - y);

        RenderTexture rt = new RenderTexture(Screen.width, Screen.height, 24);
        arCamera.targetTexture = rt;
        arCamera.Render();
        RenderTexture.active = rt;

        Texture2D tex = new Texture2D(width, height, TextureFormat.RGB24, false);
        tex.ReadPixels(new Rect(x, y, width, height), 0, 0);
        tex.Apply();

        arCamera.targetTexture = null;
        RenderTexture.active = null;
        Destroy(rt);

        string binary = "";
        int segments = 4;

        for (int i = 0; i < segments; i++)
        {
            int startX = i * width / segments + width / (segments * 4);
            int endX = (i + 1) * width / segments - width / (segments * 4);
            int startY = height / 4;
            int endY = 3 * height / 4;

            int blackCount = 0, totalCount = 0;

            for (int px = startX; px < endX; px++)
            {
                for (int py = startY; py < endY; py++)
                {
                    Color c = tex.GetPixel(px, py);
                    float brightness = (c.r + c.g + c.b) / 3f;
                    if (brightness < blackPixelThreshold)
                        blackCount++;
                    totalCount++;
                }
            }

            float ratio = (float)blackCount / totalCount;
            binary += (ratio >= blackPixelRatioThreshold) ? "1" : "0";
        }

        Destroy(tex);
        return binary;
    }
}
