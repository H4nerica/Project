using UnityEngine;
using UnityEngine.UI;

public class Debug_scanarea : MonoBehaviour
{
    [Header("UI References")]
    public Image targetImage;
    public Button toggleButton;

    [Header("Alpha Settings")]
    [Range(0f, 1f)] 
    public float normalAlpha = 1f;

    private int clickCount = 0;

    private void Start()
    {
        // set initial alpha to 0
        if (targetImage != null)
        {
            Color c = targetImage.color;
            c.a = 0f;
            targetImage.color = c;
        }

        // hook the button
        if (toggleButton != null)
            toggleButton.onClick.AddListener(OnToggleClicked);
    }

    private void OnToggleClicked()
    {
        clickCount++;

        if (clickCount == 3)
        {
            clickCount = 0;
            ToggleAlpha();
        }
    }

    private void ToggleAlpha()
    {
        Color c = targetImage.color;

        if (c.a > 0.01f)
            c.a = 0f;
        else
            c.a = normalAlpha;

        targetImage.color = c;
    }
}
