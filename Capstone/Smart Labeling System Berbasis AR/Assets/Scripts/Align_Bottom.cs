using UnityEngine;

public class Align_Bottom : MonoBehaviour
{
    [Range(0f, 1f)]
    public float paddingPercent = 0.05f;

    RectTransform rect;
    Canvas canvas;

    void Start()
    {
        rect = GetComponent<RectTransform>();
        canvas = GetComponentInParent<Canvas>();

        float screenHeight = canvas.pixelRect.height;
        float padding = screenHeight * paddingPercent;

        // height of THIS UI object
        float halfHeight = rect.rect.height * rect.pivot.y;

        Vector2 pos = rect.anchoredPosition;

        // align bottom EDGE, not pivot
        pos.y = -screenHeight / 2f + halfHeight + padding;

        rect.anchoredPosition = pos;
    }
}
