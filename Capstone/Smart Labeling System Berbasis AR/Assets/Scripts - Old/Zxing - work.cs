using UnityEngine;
using UnityEngine.UI;
using TMPro;
using ZXing;

public class GridScanner_Correct : MonoBehaviour
{
    [Header("UI & Camera")]
    public RectTransform scanArea;  // visual hint only
    public Camera arCamera;
    public TextMeshProUGUI panelText;

    [Header("Managers")]
    public ItemInfoManager infoManager;
    public EditFormController formController;

    [Header("Settings")]
    public float scanInterval = 1f;

    void Start()
    {
        InvokeRepeating(nameof(CaptureAndDecode), 0f, scanInterval);
    }

    void CaptureAndDecode()
    {
        Texture2D cropped = CaptureScanArea();
        if (cropped == null)
        {
            Debug.Log("[GridScanner] Crop returned null");
            return;
        }

        // LOG: crop info
        Debug.Log($"[GridScanner] Cropped image {cropped.width}x{cropped.height}");

        // Always try to decode, even if nothing is there
        try
        {
            var reader = new BarcodeReader();
            var result = reader.Decode(cropped.GetPixels32(), cropped.width, cropped.height);
            string code = result?.Text ?? "----";  // show ---- if nothing detected

            // LOG each scan attempt
            Debug.Log("[GridScanner] Scan attempt result: " + code);

            // Update UI anyway
            if (panelText != null)
                panelText.text = code;

            // Optional: you can still feed it to managers if needed
            CurrentMarkerID.currentID = code;
            infoManager?.ShowItemInfo(code);
            formController?.PopulateFormFields(code);
        }
        catch (System.Exception e)
        {
            Debug.LogWarning("[GridScanner] ZXing decode failed: " + e.Message);
        }

        Destroy(cropped);
    }

    Texture2D CaptureScanArea()
    {
        if (scanArea == null || arCamera == null)
            return null;

        // Get scanArea bounds in screen space
        Vector3[] corners = new Vector3[4];
        scanArea.GetWorldCorners(corners);

        Vector2 bl = RectTransformUtility.WorldToScreenPoint(null, corners[0]);
        Vector2 tr = RectTransformUtility.WorldToScreenPoint(null, corners[2]);

        int x = Mathf.RoundToInt(bl.x);
        int y = Mathf.RoundToInt(bl.y);
        int width = Mathf.RoundToInt(tr.x - bl.x);
        int height = Mathf.RoundToInt(tr.y - bl.y);

        x = Mathf.Clamp(x, 0, arCamera.pixelWidth - 1);
        y = Mathf.Clamp(y, 0, arCamera.pixelHeight - 1);
        width = Mathf.Clamp(width, 1, arCamera.pixelWidth - x);
        height = Mathf.Clamp(height, 1, arCamera.pixelHeight - y);

        RenderTexture rt = new RenderTexture(arCamera.pixelWidth, arCamera.pixelHeight, 24);
        arCamera.targetTexture = rt;
        arCamera.Render();
        RenderTexture.active = rt;

        Texture2D tex = new Texture2D(width, height, TextureFormat.RGB24, false);
        tex.ReadPixels(new Rect(x, y, width, height), 0, 0);
        tex.Apply();

        arCamera.targetTexture = null;
        RenderTexture.active = null;
        Destroy(rt);

        return tex;
    }
}
