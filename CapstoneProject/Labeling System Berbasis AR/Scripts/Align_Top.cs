using UnityEngine;

public class Align_Top : MonoBehaviour
{
    [Range(0f, 1f)]
    public float paddingPercent = 0.05f; // 5% of screen height

    private RectTransform rect;
    private Canvas canvas;

    void Start()
    {
        rect = GetComponent<RectTransform>();
        canvas = GetComponentInParent<Canvas>();

        float screenHeight = canvas.pixelRect.height;

        float padding = screenHeight * paddingPercent;

        Vector2 pos = rect.anchoredPosition;
        pos.y = screenHeight / 2f - padding; 
        rect.anchoredPosition = pos;
    }
}
