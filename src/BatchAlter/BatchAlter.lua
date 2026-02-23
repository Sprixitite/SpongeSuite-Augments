local common = require(script.Parent.Parent.ToolsCommon)

return function(propName, value)
	return function()
		local recording = common:RecordChanges(`Batch-Alter {propName}`)
		if recording == nil then return end
		
		local selection = common:GetSelection()
		local parts: {BasePart} = {}
		for _, inst in ipairs(selection) do
			if inst:IsA("BasePart") then
				parts[#parts+1] = inst
			else
				for _, collectionChild in ipairs(inst:GetDescendants()) do
					if collectionChild:IsA("BasePart") then
						parts[#parts+1] = collectionChild
					end
				end
			end
		end
		
		for _, part in ipairs(parts) do
			part[propName] = value
		end
		
		common:CommitChanges(recording, Enum.FinishRecordingOperation.Commit)
	end
end