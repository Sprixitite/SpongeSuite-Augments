# SpongeSuite // Augments
Plugin designed to augment the [official InfiltrationEngine tooling](https://github.com/MoonstoneSkies/InfiltrationEngine-Custom-Missions) and any derivative plugins.

This is the github version of this plugin, for the studio version (featuring the ability to update within studio!), see [this link](https://create.roblox.com/store/asset/75289472956203/SpongeSuite-Augments)

Currently consists of four main tools:
1) [Attribute Importer](#attribute-importer) - Automatically adds InfiltrationEngine attributes to the selected object
2) [Batch Alter](#batch-alter) - Some buttons to quickly change common properties on selected parts/children of selected containers
3) [One-Click Tools](#one-click-tools) - A collection of small assorted tools usable in a single click
3) Toggle Group Visibility - Non-destructively toggles the visibility of an entire model/folder, a'la blender's collection visibility

> [!NOTE]
> ### Now Supports Light Mode!
> Implementation is a best-effort, some tools may be missing a light mode icon as I did not want to bother making one.

## Attribute Importer
The attribute importer is a tad more elaborate than the other tools and is probably the main reason you're using the plugin to begin with

The attribute importer performs five functions, each mapped to one of the buttons shown when clicking on the "Attribute Importer" button in the toolbar. They are as follows:

### 1) Import Non-Global Attributes
Creates every attribute specific to each selected item (prop/statecomponent/bot/link etc.) provided the attribute doesn't already exist  

> [!TIP]
> Some examples of non-global attributes are:  
> - `DifficultDrill`, found on doors
> - `Path`, found on Links

### 2) Import Global Attributes
Creates every attribute that isn't specific to a single item for each item in the selection provided the attribute doesn't already exist

> [!TIP]
> Some examples of global attributes are:
> - `Color0`
> - `Tag`
> - `MultiGlass`

### 3) Import All Attributes
Performs the function of both of the prior options at the same time

### 4) Delete Imported Attributes
Deletes every known global/private attribute on every item in the selection, regardless of whether each attribute was created via the importer or not

### 5) Delete All Attributes
Deletes **EVERY** attribute on every item in the selection, regardless of whether each attribute was created via the importer or not

All of the above functions with the exception of the "Delete All Attributes" tool work on `Links`, `Bots`, `ConditionalGeometry`, `Glass`, CustomProp `Motor`s, Prop Override `Base` parts, most `Prop`s, and most `StateComponent`s, the Delete All Attributes tool functions regardless of selection

## Batch Edit
Menu providing some quick options for editing properties of all selected parts, as well as all parts parented to any selected non-parts

### Current options are:
- **Appearance**
- - CastShadow On/Off
- - Transparency 0/0.5/1
- **Physics**
- - Anchored On/Off
- - CanCollide On/Off
- **Studio**
- - Locked On/Off

## One-Click Tools
The one-click tools menu is designed to contain any small tools operable in a single button press. Currently it contains two tools:

### 1) Auto Cell
Upon use, automatically generates a best-effort InfiltrationEngine cell for the selected part(s)  
If a Model/Folder is selected, will generate the cell from all of the parts contained within the Model/Folder, and will set the Cell's title to that of the container

### 2) Cell Fixup
Upon use, fixes the styling (colour, materials, transparency, etc.) of all `Cell`s and `Link`s found within the current place file

### 3) Child Organizer
Organizes the children of all selected instances alphabetically. Useful for decluttering the hierarchy of custom props

### 4) Custom Prop Base Generator
Upon use, creates a new "Base" part in every selected model where one does not exist. Then readjusts the "Base" part in every selected model to the bounding box of the model

### 5) Generate Slope Part
For every selected Wedge, generates a part completely covering the wedge's slope