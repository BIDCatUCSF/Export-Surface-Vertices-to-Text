%  
%
%  Installation:
%
%  - Copy this file into the XTensions folder in the Imaris installation directory
%  - You will find this function in the Image Processing menu
%
%    <CustomTools>
%      <SurpassTab>
%        <SurpassComponent name="bpSpots">
%          <Item name="Export vertices" icon="Matlab" tooltip="Find spots close to surface.">
%            <Command>MatlabXT::exportVerts(%i)</Command>
%          </Item>
%        </SurpassComponent>
%        <SurpassComponent name="bpSurfaces">
%          <Item name="Export vertices" icon="Matlab" tooltip="Find spots close to surface.">
%            <Command>MatlabXT::exportVerts(%i)</Command>
%          </Item>
%        </SurpassComponent>
%      </SurpassTab>
%    </CustomTools>
% 
%
%  Description:
%   
%		Exports selected surface vertices as cartesian coordinates to a text file - that's it! 
%
%

function exportVerts(aImarisApplicationID)

% connect to Imaris interface
if ~isa(aImarisApplicationID, 'Imaris.IApplicationPrxHelper')
    javaaddpath ImarisLib.jar
    vImarisLib = ImarisLib;
    if ischar(aImarisApplicationID)
        aImarisApplicationID = round(str2double(aImarisApplicationID));
    end
    vImarisApplication = vImarisLib.GetApplication(aImarisApplicationID);
else
    vImarisApplication = aImarisApplicationID;
end

% the user has to create a scene with some spots and surface
vSurpassScene = vImarisApplication.GetSurpassScene;
if isequal(vSurpassScene, [])
    msgbox('Please create Surface in the Surpass scene!')
    return
end
vNumChans = vImarisApplication.GetDataSet.GetSizeC;
% get the spots and the surface object
vSurfaces = vImarisApplication.GetFactory.ToSurfaces(vImarisApplication.GetSurpassSelection);

vSurfaceSelected = ~isequal(vSurfaces, []);

if vSurfaceSelected
    vParent = vSurfaces.GetParent;
else
    vParent = vSurpassScene;
end

% get the spots and surfaces
vSpotsSelection = 1;
vSurfaceSelection = 1;

vNumberOfSurfaces = 0;

vSurfacesList = [];

vSurfacesName = {};
for vIndex = 1:vParent.GetNumberOfChildren
    vItem = vParent.GetChild(vIndex-1); 

    if vImarisApplication.GetFactory.IsSurfaces(vItem)
        vNumberOfSurfaces = vNumberOfSurfaces + 1;
        vSurfacesList(vNumberOfSurfaces) = vIndex;
        vSurfacesName{vNumberOfSurfaces} = char(vItem.GetName);
        
        if vSurfaceSelected && isequal(vItem.GetName, vSurfaces.GetName)
            vSurfaceSelection = vNumberOfSurfaces;
        end
    end
end

if min(vNumberOfSurfaces) == 0
    msgbox('Please create a surface object!')
    return
end


if vNumberOfSurfaces>1
    [vSurfaceSelection,vOk] = listdlg('ListString',vSurfacesName, ...
        'InitialValue', vSurfaceSelection, 'SelectionMode','multiple', ...
        'ListSize',[300 300], 'Name','Find Spots Close To Surface', ...
        'PromptString',{'Please select the surface:'});
    if vOk<1, return, end
end



% compute the distances and create new spots objects
vNumberOfSurfacesSelected = numel(vSurfaceSelection);




for vSurfaceIndex = 1:vNumberOfSurfacesSelected
    vItem = vParent.GetChild(vSurfacesList( ...
        vSurfaceSelection(vSurfaceIndex)) - 1);
    vSurface = vImarisApplication.GetFactory.ToSurfaces(vItem);

    vSurfaceVertices = [];
    for vIndex = 0:vSurface.GetNumberOfSurfaces - 1
      vSurfaceVertices = [vSurfaceVertices; vSurface.GetVertices(vIndex)];
    end
    vNumberOfVertices = size(vSurfaceVertices, 1);
    
end

% have user define the save location of the file
dir = uigetdir;
dlmwrite(strcat(dir, '/',char(vItem.GetName),'_vertices.txt'), vSurfaceVertices(:, 1:3), 'delimiter', '\t');       

    
   