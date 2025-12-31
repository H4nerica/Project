using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class EditFormController : MonoBehaviour
{
    [Header("UI References")]
    public TMP_InputField nameInput;
    public ExpiryDateInputs expiryInputs; // 3-field date input (dd, mm, yyyy)
    public TMP_InputField tagInput;
    public Button saveButton;
    public Button removeButton;

    [Header("Data Manager")]
    public ItemInfoManager infoManager; // Reference to ItemInfoManager

    private void Start()
    {
        if (saveButton != null)
            saveButton.onClick.AddListener(OnSaveClicked);

        if (removeButton != null)
            removeButton.onClick.AddListener(OnRemoveClicked);
    }

    public void PopulateFormFields(string id)
    {
        if (infoManager == null || string.IsNullOrEmpty(id))
        {
            ClearInputs();
            return;
        }

        ItemData item = infoManager.GetItemByID(id);
        if (item != null)
        {
            nameInput.text = item.name;
            tagInput.text = item.tag;

            if (!string.IsNullOrEmpty(item.expireIn) && item.expireIn.Length == 10)
            {
                expiryInputs.dayInput.text = item.expireIn.Substring(0, 2);
                expiryInputs.monthInput.text = item.expireIn.Substring(3, 2);
                expiryInputs.yearInput.text = item.expireIn.Substring(6, 4);
            }
            else
            {
                expiryInputs.dayInput.text = "";
                expiryInputs.monthInput.text = "";
                expiryInputs.yearInput.text = "";
            }
        }
        else
        {
            ClearInputs();
        }
    }

private void OnSaveClicked()
{
    string id = CurrentMarkerID.currentID;
    if (string.IsNullOrEmpty(id))
    {
        Debug.LogWarning("[EditFormController] No current ID!");
        return;
    }

    string fullDate = ""; // default blank

    // only save date if all three fields are filled
    if (!string.IsNullOrEmpty(expiryInputs.dayInput.text) &&
        !string.IsNullOrEmpty(expiryInputs.monthInput.text) &&
        !string.IsNullOrEmpty(expiryInputs.yearInput.text))
    {
        fullDate = expiryInputs.GetFullDate(); // formatted dd-mm-yyyy
    }

    ItemData data = new ItemData
    {
        id = id,
        name = nameInput.text,
        expireIn = fullDate, // either full date or blank
        tag = tagInput.text
    };

    if (infoManager != null)
    {
        infoManager.SaveItemInfo(data);
        Debug.Log("[EditFormController] Saved data for ID: " + id);
        infoManager.ShowItemInfo(id); // refresh panel
    }
}


    private void OnRemoveClicked()
    {
        string id = CurrentMarkerID.currentID;
        if (string.IsNullOrEmpty(id))
        {
            Debug.LogWarning("[EditFormController] No current ID to remove!");
            return;
        }

        if (infoManager != null)
        {
            infoManager.RemoveItemInfo(id);
            ClearInputs();
            Debug.Log("[EditFormController] Removed data for ID: " + id);
            infoManager.ShowItemInfo(id);
        }
    }

    private void ClearInputs()
    {
        nameInput.text = "";
        expiryInputs.dayInput.text = "";
        expiryInputs.monthInput.text = "";
        expiryInputs.yearInput.text = "";
        tagInput.text = "";
    }
}
