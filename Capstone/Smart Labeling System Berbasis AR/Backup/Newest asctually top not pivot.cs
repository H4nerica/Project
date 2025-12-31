using UnityEngine;

[ExecuteAlways] // optional, updates in editor
public class Align_Top : MonoBehaviour
{
    [Range(0f, 1f)]
    public float paddingPercent = 0.05f; // 5% of screen height

    private RectTransform rect;
    private Canvas canvas;

    void Start()
    {
        AlignTop();
    }

#if UNITY_EDITOR
    void Update()
    {
        // optional: keep it aligned in editor while adjusting
        if (!Application.isPlaying)
            AlignTop();
    }
#endif

    void AlignTop()
    {
        rect = rect ?? GetComponent<RectTransform>();
        canvas = canvas ?? GetComponentInParent<Canvas>();

        if (rect == null || canvas == null)
            return;

        float screenHeight = canvas.pixelRect.height;
        float padding = screenHeight * paddingPercent;

        Vector2 pos = rect.anchoredPosition;

        // Align top edge of the rect
        pos.y = screenHeight / 2f - rect.rect.height * (1 - rect.pivot.y) - padding;

        rect.anchoredPosition = pos;
    }
}
