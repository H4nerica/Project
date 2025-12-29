using UnityEngine;
using UnityEngine.UI;

public class Recent_Button : MonoBehaviour
{
    [Header("UI References")]
    public GameObject targetCanvas; // the canvas or panel to show/hide
    public Button showButton;       // button to show the canvas
    public Button hideButton;       // button to hide the canvas

    void Awake()
    {
        // Default hidden
        if (targetCanvas != null)
            targetCanvas.SetActive(false);

        // Setup show button
        if (showButton != null)
        {
            showButton.onClick.RemoveAllListeners();
            showButton.onClick.AddListener(ShowCanvas);
        }

        // Setup hide button
        if (hideButton != null)
        {
            hideButton.onClick.RemoveAllListeners();
            hideButton.onClick.AddListener(HideCanvas);
        }
    }

    void ShowCanvas()
    {
        if (targetCanvas != null)
            targetCanvas.SetActive(true);
    }

    void HideCanvas()
    {
        if (targetCanvas != null)
            targetCanvas.SetActive(false);
    }
}
