using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class EditFormController : MonoBehaviour
{
    [Header("UI References")]
    public TMP_InputField nameInput;
    public ExpiryDateInputs expiryInputs; // dd / mm / yyyy
    public TMP_InputField tagInput;
    public Button saveButton;
    public Button removeButton;

    [Header("Data Manager")]
    public ItemInfoManager infoManager;

    [Header("Overlay Canvas")]
    public GameObject overlayEdit; // assign the canvas here

    private string lockedID;

    private void Start()
    {
        if (saveButton != null)
            saveButton.onClick.AddListener(OnSaveClicked);

        if (removeButton != null)
            removeButton.onClick.AddListener(OnRemoveClicked);
    }

    private void Update()
    {
        if (overlayEdit == null) return;

        // Unlock ID and clear form when overlay hides
        if (!overlayEdit.activeSelf && !string.IsNullOrEmpty(lockedID))
        {
            UnlockID();
            ClearInputs();
        }
    }

    public void PopulateFormFields(string id)
    {
        if (string.IsNullOrEmpty(id) || infoManager == null) return;

        ItemData item = infoManager.GetItemByID(id);
        if (item == null)
        {
            ClearInputs();
            return;
        }

        nameInput.text = item.name;
        tagInput.text = item.tag;

        if (!string.IsNullOrEmpty(item.expireIn) && item.expireIn.Length == 10)
        {
            expiryInputs.dayInput.text   = item.expireIn.Substring(0, 2);
            expiryInputs.monthInput.text = item.expireIn.Substring(3, 2);
            expiryInputs.yearInput.text  = item.expireIn.Substring(6, 4);
        }
        else
        {
            expiryInputs.dayInput.text   = "";
            expiryInputs.monthInput.text = "";
            expiryInputs.yearInput.text  = "";
        }
    }

    private void OnSaveClicked()
    {
        if (string.IsNullOrEmpty(lockedID)) return;

        string date = expiryInputs.GetFullDate();
        if (string.IsNullOrEmpty(date) || date == "--") date = "";

        ItemData data = new ItemData
        {
            id = lockedID,
            name = nameInput.text,
            expireIn = date,
            tag = tagInput.text
        };

        if (infoManager != null)
        {
            infoManager.SaveItemInfo(data);
            infoManager.ShowItemInfo(lockedID);
        }
    }

    private void OnRemoveClicked()
    {
        if (string.IsNullOrEmpty(lockedID)) return;
        ClearInputs();
    }

    private void UnlockID()
    {
        lockedID = null;
    }

    private void ClearInputs()
    {
        nameInput.text = "";
        expiryInputs.dayInput.text = "";
        expiryInputs.monthInput.text = "";
        expiryInputs.yearInput.text = "";
        tagInput.text = "";
    }

    // Force populate form on every scan
public void LockAndPopulate(string id)
{
    if (string.IsNullOrEmpty(id) || infoManager == null) return;

    lockedID = id;          // lock current ID
    PopulateFormFields(id); // always populate form
}

}
