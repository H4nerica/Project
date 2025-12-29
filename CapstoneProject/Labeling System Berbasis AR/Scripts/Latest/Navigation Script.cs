using UnityEngine;
using UnityEngine.UI;

public class NavigationSciprt : MonoBehaviour
{
    public GameObject overlayEdit;

    public Button editButton;
    public Button closeButton;

    void Awake()
    {
        // DEFAULT: hidden
        overlayEdit.SetActive(false);

        editButton.onClick.RemoveAllListeners();
        closeButton.onClick.RemoveAllListeners();

        editButton.onClick.AddListener(ShowEdit);
        closeButton.onClick.AddListener(HideEdit);
    }

    void ShowEdit()
    {
        overlayEdit.SetActive(true);
    }

    void HideEdit()
    {
        overlayEdit.SetActive(false);
    }
}