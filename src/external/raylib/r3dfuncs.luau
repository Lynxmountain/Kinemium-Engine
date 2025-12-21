--!strict
--!optimize 2
--!native

local ffi = zune.ffi

-- Basic type aliases
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local double = ffi.types.double

-- Struct definitions
local R3D_AnimationTrack = ffi.struct({
	{ times = ffi.types.pointer },
	{ values = ffi.types.pointer },
	{ count = ffi.types.i32 },
})
export type R3D_AnimationTrack = typeof(R3D_AnimationTrack:new({}))

local R3D_AnimationChannel = ffi.struct({
	{ translation = R3D_AnimationTrack },
	{ rotation = R3D_AnimationTrack },
	{ scale = R3D_AnimationTrack },
	{ boneIndex = ffi.types.i32 },
})
export type R3D_AnimationChannel = typeof(R3D_AnimationChannel:new({}))

local R3D_Animation = ffi.struct({
	{ channels = ffi.types.pointer },
	{ channelCount = ffi.types.i32 },
	{ ticksPerSecond = ffi.types.float },
	{ duration = ffi.types.float },
	{ boneCount = ffi.types.i32 },
	{ name = ffi.types.pointer:array(32) },
})
export type R3D_Animation = typeof(R3D_Animation:new({}))

local R3D_AnimationLib = ffi.struct({
	{ animations = ffi.types.pointer },
	{ count = ffi.types.i32 },
})
export type R3D_AnimationLib = typeof(R3D_AnimationLib:new({}))

local R3D_AnimationState = ffi.struct({
	{ currentTime = ffi.types.float },
	{ weight = ffi.types.float },
	{ loop = ffi.types.u8 },
})
export type R3D_AnimationState = typeof(R3D_AnimationState:new({}))

local R3D_AnimationPlayer = ffi.struct({
	{ states = ffi.types.pointer },
	{ animLib = R3D_AnimationLib },
	{ skeleton = ffi.types.pointer },
	{ currentPose = ffi.types.pointer },
})
export type R3D_AnimationPlayer = typeof(R3D_AnimationPlayer:new({}))

local R3D_Keyframe = ffi.struct({
	{ time = ffi.types.float },
	{ value = ffi.types.float },
})
export type R3D_Keyframe = typeof(R3D_Keyframe:new({}))

local R3D_InterpolationCurve = ffi.struct({
	{ keyframes = ffi.types.pointer },
	{ capacity = ffi.types.i32 },
	{ count = ffi.types.i32 },
})
export type R3D_InterpolationCurve = typeof(R3D_InterpolationCurve:new({}))

local R3D_Decal = ffi.struct({
	{ material = ffi.types.pointer },
})
export type R3D_Decal = typeof(R3D_Decal:new({}))

local albedo = ffi.struct({
	{ texture = ffi.types.pointer },
	{ color = ffi.types.pointer },
})
export type albedo = typeof(albedo:new({}))

local R3D_Mesh = ffi.struct({
	{ shadowCastMode = ffi.types.pointer },
	{ primitiveType = ffi.types.pointer },
	{ usage = ffi.types.pointer },
	{ layerMask = ffi.types.pointer },
	{ aabb = ffi.types.pointer },
})
export type R3D_Mesh = typeof(R3D_Mesh:new({}))

local R3D_Vertex = ffi.struct({
	{ position = ffi.types.pointer },
	{ texcoord = ffi.types.pointer },
	{ normal = ffi.types.pointer },
	{ color = ffi.types.pointer },
	{ tangent = ffi.types.pointer },
	{ boneIds = ffi.types.i32:array(4) },
	{ weights = ffi.types.float:array(4) },
})
export type R3D_Vertex = typeof(R3D_Vertex:new({}))

local R3D_MeshData = ffi.struct({
	{ vertices = ffi.types.pointer },
	{ indices = ffi.types.pointer },
	{ vertexCount = ffi.types.i32 },
	{ indexCount = ffi.types.i32 },
})
export type R3D_MeshData = typeof(R3D_MeshData:new({}))

local R3D_Model = ffi.struct({
	{ meshes = ffi.types.pointer },
	{ materials = ffi.types.pointer },
	{ meshMaterials = ffi.types.pointer },
	{ meshCount = ffi.types.i32 },
	{ materialCount = ffi.types.i32 },
	{ aabb = ffi.types.pointer },
	{ skeleton = ffi.types.pointer },
	{ player = ffi.types.pointer },
})
export type R3D_Model = typeof(R3D_Model:new({}))

local R3D_Particle = ffi.struct({
	{ lifetime = ffi.types.float },
	{ transform = ffi.types.pointer },
	{ position = ffi.types.pointer },
	{ rotation = ffi.types.pointer },
	{ scale = ffi.types.pointer },
	{ color = ffi.types.pointer },
	{ velocity = ffi.types.pointer },
	{ angularVelocity = ffi.types.pointer },
	{ baseScale = ffi.types.pointer },
	{ baseVelocity = ffi.types.pointer },
	{ baseAngularVelocity = ffi.types.pointer },
	{ baseOpacity = ffi.types.pointer },
})
export type R3D_Particle = typeof(R3D_Particle:new({}))

local R3D_ParticleSystem = ffi.struct({
	{ particles = ffi.types.pointer },
	{ capacity = ffi.types.i32 },
	{ count = ffi.types.i32 },
	{ position = ffi.types.pointer },
	{ gravity = ffi.types.pointer },
	{ initialScale = ffi.types.pointer },
	{ scaleVariance = ffi.types.float },
	{ initialRotation = ffi.types.pointer },
	{ rotationVariance = ffi.types.pointer },
	{ initialColor = ffi.types.pointer },
	{ colorVariance = ffi.types.pointer },
	{ initialVelocity = ffi.types.pointer },
	{ velocityVariance = ffi.types.pointer },
	{ initialAngularVelocity = ffi.types.pointer },
	{ angularVelocityVariance = ffi.types.pointer },
	{ lifetime = ffi.types.float },
	{ lifetimeVariance = ffi.types.float },
	{ emissionTimer = ffi.types.float },
	{ emissionRate = ffi.types.float },
	{ spreadAngle = ffi.types.float },
	{ scaleOverLifetime = ffi.types.pointer },
	{ speedOverLifetime = ffi.types.pointer },
	{ opacityOverLifetime = ffi.types.pointer },
	{ angularVelocityOverLifetime = ffi.types.pointer },
	{ aabb = ffi.types.pointer },
	{ autoEmission = ffi.types.u8 },
})
export type R3D_ParticleSystem = typeof(R3D_ParticleSystem:new({}))

local R3D_BoneInfo = ffi.struct({
	{ name = ffi.types.pointer:array(32) },
	{ parent = ffi.types.i32 },
})
export type R3D_BoneInfo = typeof(R3D_BoneInfo:new({}))

local R3D_Skeleton = ffi.struct({
	{ bones = ffi.types.pointer },
	{ boneCount = ffi.types.i32 },
	{ boneOffsets = ffi.types.pointer },
	{ bindLocal = ffi.types.pointer },
	{ bindPose = ffi.types.pointer },
})
export type R3D_Skeleton = typeof(R3D_Skeleton:new({}))

local R3D_Skybox = ffi.struct({
	{ cubemap = ffi.types.pointer },
	{ irradiance = ffi.types.pointer },
	{ prefilter = ffi.types.pointer },
})
export type R3D_Skybox = typeof(R3D_Skybox:new({}))

-- Function definitions
local funcs = {
	R3D_LoadAnimationLib = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_LoadAnimationLibFromMemory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	R3D_UnloadAnimationLib = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetAnimationIndex = { returns = ffi.types.i32, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GetAnimation = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_LoadAnimationPlayer = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_UnloadAnimationPlayer = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_AdvanceAnimationPlayerTime = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_CalculateAnimationPlayerPose = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_UpdateAnimationPlayer = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_Init = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32, ffi.types.u32 } },
	R3D_Close = { returns = ffi.types.void, args = {} },
	R3D_HasState = { returns = ffi.types.u8, args = { ffi.types.u32 } },
	R3D_SetState = { returns = ffi.types.void, args = { ffi.types.u32 } },
	R3D_ClearState = { returns = ffi.types.void, args = { ffi.types.u32 } },
	R3D_GetResolution = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_UpdateResolution = { returns = ffi.types.void, args = { ffi.types.i32, ffi.types.i32 } },
	R3D_SetSceneBounds = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_SetTextureFilter = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetActiveLayers = { returns = ffi.types.pointer, args = {} },
	R3D_SetActiveLayers = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_EnableLayers = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_DisableLayers = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_LoadInterpolationCurve = { returns = ffi.types.pointer, args = { ffi.types.i32 } },
	R3D_UnloadInterpolationCurve = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_AddKeyframe = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.float, ffi.types.float } },
	R3D_EvaluateCurve = { returns = ffi.types.float, args = { ffi.types.pointer, ffi.types.float } },
	R3D_Begin = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_BeginEx = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_End = { returns = ffi.types.void, args = {} },
	R3D_DrawMesh = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	R3D_DrawMeshInstanced = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_DrawMeshInstancedEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_DrawMeshInstancedPro = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
		},
	},
	R3D_DrawModel = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.float } },
	R3D_DrawModelEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.float, ffi.types.pointer },
	},
	R3D_DrawModelPro = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_DrawModelInstanced = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_DrawModelInstancedEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_DrawModelInstancedPro = {
		returns = ffi.types.void,
		args = {
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.pointer,
			ffi.types.i32,
			ffi.types.i32,
		},
	},
	R3D_DrawDecal = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_DrawDecalInstanced = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.i32 },
	},
	R3D_DrawParticleSystem = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_DrawParticleSystemEx = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SetBackgroundColor = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_SetAmbientColor = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_SetAmbientEnergy = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_EnableSkybox = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_DisableSkybox = { returns = ffi.types.void, args = {} },
	R3D_SetSkyboxRotation = { returns = ffi.types.void, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
	R3D_GetSkyboxRotation = { returns = ffi.types.pointer, args = {} },
	R3D_SetSkyboxIntensity = { returns = ffi.types.void, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
	R3D_GetSkyboxIntensity = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_SetSSAO = { returns = ffi.types.void, args = { ffi.types.u8 } },
	R3D_SetSSAORadius = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetSSAORadius = { returns = ffi.types.float, args = {} },
	R3D_SetSSAOBias = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetSSAOBias = { returns = ffi.types.float, args = {} },
	R3D_SetSSAOIterations = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_GetSSAOIterations = { returns = ffi.types.i32, args = {} },
	R3D_SetSSAOIntensity = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetSSAOIntensity = { returns = ffi.types.float, args = {} },
	R3D_SetSSAOPower = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetSSAOPower = { returns = ffi.types.float, args = {} },
	R3D_SetSSAOLightAffect = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetSSAOLightAffect = { returns = ffi.types.float, args = {} },
	R3D_SetBloomMode = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetBloomMode = { returns = ffi.types.pointer, args = {} },
	R3D_SetBloomLevels = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_GetBloomLevels = { returns = ffi.types.i32, args = {} },
	R3D_SetBloomIntensity = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetBloomIntensity = { returns = ffi.types.float, args = {} },
	R3D_SetBloomFilterRadius = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_GetBloomFilterRadius = { returns = ffi.types.i32, args = {} },
	R3D_SetBloomThreshold = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetBloomThreshold = { returns = ffi.types.float, args = {} },
	R3D_SetBloomSoftThreshold = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetBloomSoftThreshold = { returns = ffi.types.float, args = {} },
	R3D_SetSSR = { returns = ffi.types.void, args = { ffi.types.u8 } },
	R3D_GetSSR = { returns = ffi.types.u8, args = {} },
	R3D_SetSSRMaxRaySteps = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_GetSSRMaxRaySteps = { returns = ffi.types.i32, args = {} },
	R3D_SetSSRBinarySearchSteps = { returns = ffi.types.void, args = { ffi.types.i32 } },
	R3D_GetSSRBinarySearchSteps = { returns = ffi.types.i32, args = {} },
	R3D_SetSSRRayMarchLength = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetSSRRayMarchLength = { returns = ffi.types.float, args = {} },
	R3D_SetSSRDepthThickness = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetSSRDepthThickness = { returns = ffi.types.float, args = {} },
	R3D_SetSSRDepthTolerance = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetSSRDepthTolerance = { returns = ffi.types.float, args = {} },
	R3D_SetSSRScreenEdgeFade = { returns = ffi.types.void, args = { ffi.types.float, ffi.types.float } },
	R3D_GetSSRScreenEdgeFade = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_SetFogMode = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetFogMode = { returns = ffi.types.pointer, args = {} },
	R3D_SetFogColor = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetFogColor = { returns = ffi.types.pointer, args = {} },
	R3D_SetFogStart = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetFogStart = { returns = ffi.types.float, args = {} },
	R3D_SetFogEnd = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetFogEnd = { returns = ffi.types.float, args = {} },
	R3D_SetFogDensity = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetFogDensity = { returns = ffi.types.float, args = {} },
	R3D_SetFogSkyAffect = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetFogSkyAffect = { returns = ffi.types.float, args = {} },
	R3D_SetDofMode = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetDofMode = { returns = ffi.types.pointer, args = {} },
	R3D_SetDofFocusPoint = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetDofFocusPoint = { returns = ffi.types.float, args = {} },
	R3D_SetDofFocusScale = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetDofFocusScale = { returns = ffi.types.float, args = {} },
	R3D_SetDofMaxBlurSize = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetDofMaxBlurSize = { returns = ffi.types.float, args = {} },
	R3D_SetDofDebugMode = { returns = ffi.types.void, args = { ffi.types.u8 } },
	R3D_GetDofDebugMode = { returns = ffi.types.u8, args = {} },
	R3D_SetTonemapMode = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetTonemapMode = { returns = ffi.types.pointer, args = {} },
	R3D_SetTonemapExposure = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetTonemapExposure = { returns = ffi.types.float, args = {} },
	R3D_SetTonemapWhite = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetTonemapWhite = { returns = ffi.types.float, args = {} },
	R3D_SetBrightness = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetBrightness = { returns = ffi.types.float, args = {} },
	R3D_SetContrast = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetContrast = { returns = ffi.types.float, args = {} },
	R3D_SetSaturation = { returns = ffi.types.void, args = { ffi.types.float } },
	R3D_GetSaturation = { returns = ffi.types.float, args = {} },
	R3D_CreateLight = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_DestroyLight = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_IsLightExist = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_GetLightType = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_IsLightActive = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_ToggleLight = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_SetLightActive = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	R3D_GetLightColor = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_GetLightColorV = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_SetLightColor = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_SetLightColorV = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GetLightPosition = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_SetLightPosition = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GetLightDirection = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_SetLightDirection = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_LightLookAt = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	R3D_GetLightEnergy = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetLightEnergy = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_GetLightSpecular = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetLightSpecular = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_GetLightRange = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetLightRange = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_GetLightAttenuation = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetLightAttenuation = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_GetLightInnerCutOff = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetLightInnerCutOff = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_GetLightOuterCutOff = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetLightOuterCutOff = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_EnableShadow = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_DisableShadow = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	R3D_IsShadowEnabled = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_HasShadowMap = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_GetShadowUpdateMode = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_SetShadowUpdateMode = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GetShadowUpdateFrequency = { returns = ffi.types.i32, args = { ffi.types.pointer } },
	R3D_SetShadowUpdateFrequency = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_UpdateShadowMap = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetShadowSoftness = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetShadowSoftness = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_GetShadowDepthBias = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetShadowDepthBias = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_GetShadowSlopeBias = { returns = ffi.types.float, args = { ffi.types.pointer } },
	R3D_SetShadowSlopeBias = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_GetLightBoundingBox = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_DrawLightShape = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetDefaultMaterial = { returns = ffi.types.pointer, args = {} },
	R3D_UnloadMaterial = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_LoadMesh = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_UnloadMesh = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_IsMeshValid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_GenMeshQuad = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	R3D_GenMeshPlane = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshPoly = { returns = ffi.types.pointer, args = { ffi.types.i32, ffi.types.float } },
	R3D_GenMeshCube = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
	R3D_GenMeshSphere = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.i32, ffi.types.i32 } },
	R3D_GenMeshHemiSphere = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.i32, ffi.types.i32 } },
	R3D_GenMeshCylinder = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.float, ffi.types.i32 } },
	R3D_GenMeshCone = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.float, ffi.types.i32 } },
	R3D_GenMeshTorus = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshKnot = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshHeightmap = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GenMeshCubicmap = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_UpdateMesh = { returns = ffi.types.u8, args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer } },
	R3D_CreateMeshData = { returns = ffi.types.pointer, args = { ffi.types.i32, ffi.types.i32 } },
	R3D_UnloadMeshData = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_IsMeshDataValid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_GenMeshDataQuad = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32, ffi.types.pointer },
	},
	R3D_GenMeshDataPlane = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataPoly = { returns = ffi.types.pointer, args = { ffi.types.i32, ffi.types.float } },
	R3D_GenMeshDataCube = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.float, ffi.types.float } },
	R3D_GenMeshDataSphere = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.i32, ffi.types.i32 } },
	R3D_GenMeshDataHemiSphere = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataCylinder = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32 },
	},
	R3D_GenMeshDataCone = { returns = ffi.types.pointer, args = { ffi.types.float, ffi.types.float, ffi.types.i32 } },
	R3D_GenMeshDataTorus = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataKnot = {
		returns = ffi.types.pointer,
		args = { ffi.types.float, ffi.types.float, ffi.types.i32, ffi.types.i32 },
	},
	R3D_GenMeshDataHeightmap = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GenMeshDataCubicmap = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_DuplicateMeshData = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_MergeMeshData = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_TranslateMeshData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_RotateMeshData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_ScaleMeshData = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_GenMeshDataUVsPlanar = {
		returns = ffi.types.void,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	R3D_GenMeshDataUVsSpherical = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GenMeshDataUVsCylindrical = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GenMeshDataNormals = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GenMeshDataTangents = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_CalculateMeshDataBoundingBox = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_LoadModel = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_LoadModelFromMemory = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	R3D_LoadModelFromMesh = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_UnloadModel = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.u8 } },
	R3D_LoadParticleSystem = { returns = ffi.types.pointer, args = { ffi.types.i32 } },
	R3D_UnloadParticleSystem = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_EmitParticle = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_UpdateParticleSystem = { returns = ffi.types.void, args = { ffi.types.pointer, ffi.types.float } },
	R3D_CalculateParticleSystemBoundingBox = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_LoadSkeleton = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	R3D_LoadSkeletonFromData = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	R3D_UnloadSkeleton = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_IsSkeletonValid = { returns = ffi.types.u8, args = { ffi.types.pointer } },
	R3D_LoadSkybox = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_LoadSkyboxFromMemory = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.pointer } },
	R3D_LoadSkyboxPanorama = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_LoadSkyboxPanoramaFromMemory = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.i32 } },
	R3D_UnloadSkybox = { returns = ffi.types.void, args = { ffi.types.pointer } },
	R3D_GetWhiteTexture = { returns = ffi.types.pointer, args = {} },
	R3D_GetBlackTexture = { returns = ffi.types.pointer, args = {} },
	R3D_GetNormalTexture = { returns = ffi.types.pointer, args = {} },
	R3D_GetBufferColor = { returns = ffi.types.pointer, args = {} },
	R3D_GetBufferNormal = { returns = ffi.types.pointer, args = {} },
	R3D_GetBufferDepth = { returns = ffi.types.pointer, args = {} },
	R3D_GetMatrixView = { returns = ffi.types.pointer, args = {} },
	R3D_GetMatrixInvView = { returns = ffi.types.pointer, args = {} },
	R3D_GetMatrixProjection = { returns = ffi.types.pointer, args = {} },
	R3D_GetMatrixInvProjection = { returns = ffi.types.pointer, args = {} },
	R3D_DrawBufferAlbedo = {
		returns = ffi.types.void,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	R3D_DrawBufferEmission = {
		returns = ffi.types.void,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	R3D_DrawBufferNormal = {
		returns = ffi.types.void,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	R3D_DrawBufferORM = {
		returns = ffi.types.void,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	R3D_DrawBufferSSAO = {
		returns = ffi.types.void,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
	},
	R3D_DrawBufferBloom = {
		returns = ffi.types.void,
		args = { ffi.types.float, ffi.types.float, ffi.types.float, ffi.types.float },
	},
}

local structs = {
	R3D_AnimationTrack = R3D_AnimationTrack,
	R3D_AnimationChannel = R3D_AnimationChannel,
	R3D_Animation = R3D_Animation,
	R3D_AnimationLib = R3D_AnimationLib,
	R3D_AnimationState = R3D_AnimationState,
	R3D_AnimationPlayer = R3D_AnimationPlayer,
	R3D_Keyframe = R3D_Keyframe,
	R3D_InterpolationCurve = R3D_InterpolationCurve,
	R3D_Decal = R3D_Decal,
	albedo = albedo,
	R3D_Mesh = R3D_Mesh,
	R3D_Vertex = R3D_Vertex,
	R3D_MeshData = R3D_MeshData,
	R3D_Model = R3D_Model,
	R3D_Particle = R3D_Particle,
	R3D_ParticleSystem = R3D_ParticleSystem,
	R3D_BoneInfo = R3D_BoneInfo,
	R3D_Skeleton = R3D_Skeleton,
	R3D_Skybox = R3D_Skybox,
}

return { funcs = funcs, structs = structs }
