local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")

return {
	class = "Model",
	callback = function(instance)
		function instance:SetPrimaryPart(part)
			self.PrimaryPart = part
		end

		function instance:GetPrimaryPartCFrame()
			return self.PrimaryPart and self.PrimaryPart.CFrame or self.WorldPivot
		end

		function instance:GetPivot()
			return self.WorldPivot
		end

		function instance:PivotTo(cf)
			local offset = cf * self.WorldPivot:Inverse()
			self.WorldPivot = cf

			for _, child in ipairs(self:GetChildren()) do
				if child.CFrame then
					child.CFrame = offset * child.CFrame
				end
			end
		end

		function instance:MoveTo(pos)
			local current = self:GetPrimaryPartCFrame()
			self:PivotTo(CFrame.new(pos) * current:ToObjectSpace(current))
		end

		function instance:ScaleTo(targetSize)
			local current = self:GetExtentsSize()
			local scale = Vector3.new(targetSize.X / current.X, targetSize.Y / current.Y, targetSize.Z / current.Z)

			for _, child in ipairs(self:GetChildren()) do
				if child.Size then
					child.Size = Vector3.new(child.Size.X * scale.X, child.Size.Y * scale.Y, child.Size.Z * scale.Z)

					child.CFrame = self.WorldPivot + ((child.CFrame.Position - self.WorldPivot.Position) * scale)
				end
			end
		end

		function instance:SetPivot(cf)
			local offset = cf * self.WorldPivot:Inverse()
			self.WorldPivot = cf

			for _, child in ipairs(self:GetChildren()) do
				if child.CFrame then
					child.CFrame = offset * child.CFrame
				end
			end
		end

		function instance:GetBoundingBox()
			local pivot = self.WorldPivot
			local size = self:GetExtentsSize()
			return pivot, size
		end

		function instance:GetExtentsSize()
			local minVec = Vector3.new(math.huge, math.huge, math.huge)
			local maxVec = Vector3.new(-math.huge, -math.huge, -math.huge)

			for _, child in ipairs(self:GetChildren()) do
				if child.Size and child.CFrame then
					local half = child.Size / 2
					local cf = child.CFrame

					local corners = {
						cf * Vector3.new(half.X, half.Y, half.Z),
						cf * Vector3.new(half.X, half.Y, -half.Z),
						cf * Vector3.new(half.X, -half.Y, half.Z),
						cf * Vector3.new(half.X, -half.Y, -half.Z),
						cf * Vector3.new(-half.X, half.Y, half.Z),
						cf * Vector3.new(-half.X, half.Y, -half.Z),
						cf * Vector3.new(-half.X, -half.Y, half.Z),
						cf * Vector3.new(-half.X, -half.Y, -half.Z),
					}

					for _, p in ipairs(corners) do
						minVec = Vector3.new(math.min(minVec.X, p.X), math.min(minVec.Y, p.Y), math.min(minVec.Z, p.Z))
						maxVec = Vector3.new(math.max(maxVec.X, p.X), math.max(maxVec.Y, p.Y), math.max(maxVec.Z, p.Z))
					end
				end
			end

			return maxVec - minVec
		end

		return instance
	end,
}
