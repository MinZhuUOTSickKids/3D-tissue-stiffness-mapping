#!/usr/bin/python3
import numpy as np
import scipy as sp
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D, axes3d
#mpl.style.use('~/SickKids/Python/papersrc.py')
from scipy.spatial import Delaunay

# Make axes in a 3d plot have the same aspect ratio.    
def AxisEqual3D(ax):
    extents = np.array([getattr(ax, 'get_{}lim'.format(dim))() for dim in 'xyz'])
    sz = extents[:,1] - extents[:,0]
    centers = np.mean(extents, axis=1)
    maxsize = max(abs(sz))
    r = maxsize/2
    for ctr, dim in zip(centers, 'xyz'):
        getattr(ax, 'set_{}lim'.format(dim))(ctr - r, ctr + r)

def ConnectNodes(ax, A, B, fmt='-', color='k', linewidth=.5):
    ax.plot([A[0], B[0]], [A[1], B[1]], [A[2], B[2]], fmt, color=color, lw=linewidth)

# http://mathworld.wolfram.com/Plane.html  Returns a, b, c, d when the plane is ax + by + cz + d = 0
def PlaneEquation(p1, p2, p3):
    n = np.cross(p2-p1, p3-p1)
    n = n / np.linalg.norm(n)
    d = -1*np.dot(n, p1)
    return n[0], n[1], n[2], d

def ProjectPointToPlane(p, plane): # p is [x,y,z], and plane is an array of 4 values, a,b,c,d where normal = [a,b,c]. You know the drill.
    n = np.array(plane[0:3])/np.linalg.norm(plane[0:3])
    q = np.array([0,0,-plane[3]/plane[2]])
    dist = (p-q).dot(n)
    return p-dist*n

def BaryCentericValue(triangleNodes, values, point):
    plane = PlaneEquation(triangleNodes[0,:], triangleNodes[1,:], triangleNodes[2,:])
    pp = ProjectPointToPlane(point, plane)

    areaT = np.zeros(3)
    # These areas are actually twice areas, but since they get divided by each other, no one gives a fuck.
    for i in range(3):
        j = (i+1)%3
        k = (i+2)%3
        areaT[i] = np.abs(np.linalg.norm(np.cross(triangleNodes[j]-triangleNodes[k], pp - triangleNodes[k])))
    area  = np.sum(areaT)
    
    return np.sum([areaT[i] * values[i]])/area
    
def RefineSurface(nodes, surfaces, iterations):
    fineNodes = nodes.copy()
    fineSurfaces = surfaces.copy()
    for it in range(iterations):
        newSurfaces = np.zeros((0,3), dtype=int)
        midNodes = np.zeros((len(fineNodes),len(fineNodes)), dtype=int)-1
        for s_i, s in enumerate(fineSurfaces):
            nn = np.zeros(6, dtype=int)
            nn[0:3] = s
            for i in range(3):
                j = (i+1)%3
                k = (i+2)%3
                if midNodes[s[j],s[k]] == -1:
                    midNodeId = len(fineNodes)
                    newNode = (fineNodes[s[j]] +  fineNodes[s[k]]) / 2.
                    fineNodes = np.vstack([fineNodes, newNode])
                    midNodes[s[j],s[k]] = midNodeId
                    midNodes[s[k],s[j]] = midNodeId
                    #print("({0:d},{1:d}) = {2:d}".format(s[k],s[j], midNodeId))
                else:
                    midNodeId = midNodes[s[j],s[k]]
                nn[i+3] = midNodeId
            # Add triangles
            newSurfaces = np.vstack([newSurfaces, [nn[0], nn[5], nn[4]]])
            newSurfaces = np.vstack([newSurfaces, [nn[5], nn[1], nn[3]]])
            newSurfaces = np.vstack([newSurfaces, [nn[4], nn[3], nn[2]]])
            newSurfaces = np.vstack([newSurfaces, [nn[4], nn[5], nn[3]]])
        fineSurfaces = newSurfaces
    return fineNodes, fineSurfaces
    
def Generate3DSurface(x,y,z,d,dataLabel,refineLevel=2):
    nodes = np.vstack([x,y,z]).T
    surfaces = Delaunay(nodes).convex_hull
    
    fineNodes, fineSurfaces = RefineSurface(nodes, surfaces, refineLevel)
    fineValues = np.zeros(len(fineSurfaces))
    fineCentroids = np.mean(fineNodes[fineSurfaces[:,:]], axis=1)
    for fi,fs in enumerate(fineSurfaces):
        oi = int(fi/4**refineLevel)
        os = surfaces[oi]
        fineValues[fi] = BaryCentericValue(nodes[os], d[os], fineCentroids[fi])

    normalizedFineValues = (fineValues - np.min(fineValues))/(np.max(fineValues) - np.min(fineValues))

    fig = plt.figure(figsize=(8,8))
    ax = Axes3D(fig)
    #ax.plot(x,y,z, '.k')
    surfColors = np.zeros(len(fineSurfaces))
    
    for i,s in enumerate(fineSurfaces):
        ax.plot_trisurf(fineNodes[:,0], fineNodes[:,1], fineNodes[:,2], triangles=[s], color=cm.jet(normalizedFineValues[i]))

    for srf_i, srf in enumerate(fineSurfaces):
        for i in range(3):
            j = (i+1)%3
            ConnectNodes(ax, fineNodes[srf[i]], fineNodes[srf[j]])
            
    AxisEqual3D(ax)
    plt.show()

# Expects 4 points
def TethreahedronVolume(points):
    vecs = np.array([points[i+1]-points[0] for i in range(3)])
    return np.abs(np.cross(vecs[0],vecs[1]).dot(vecs[2])/6.)
    
def InterpolateValue(nodes, elements, d, point):
    for e_i, e in enumerate(elements):
        # Is point inside this tetrahedron?
        # http://steve.hollasch.net/cgindex/geometry/ptintet.html
        dets = np.zeros(5)
        D = np.column_stack([nodes[e], [1.,1.,1.,1.]])
        dets[0] = np.linalg.det(D)
        for i in range(1,5):
            D = np.column_stack([nodes[e], [1.,1.,1.,1.]])
            D[i-1,0:3] = point
            dets[i] = np.linalg.det(D)
        
        if np.all(dets < 0) or np.all(dets > 0):
            # We're inside the current element (tetrahedron)
            vols = np.zeros(4)
            totalVol = TethreahedronVolume(nodes[e])
            for i in range(4):
                tetpoints = nodes[e]
                tetpoints[i,:] = point
                vols[i] = TethreahedronVolume(tetpoints)
            vals = d[e]
            return np.sum([vols[i] * vals[i] for i in range(4)])/totalVol
    return None

def GeneratePlaneCuts(x,y,z,d,dataLabel,zcut,resolution):
    nodes = np.vstack([x,y,z]).T
    elements = Delaunay(nodes).simplices
    
    z = np.min(z) + (np.max(z) - np.min(z))*zcut
    rect = [np.min(x), np.min(y), np.max(x), np.max(y)]
    
    divider = np.round(10*np.exp(-1.4*resolution))
    Nx = int(np.max(x)/divider - np.min(x)/divider)
    Ny = int(np.max(y)/divider - np.min(y)/divider)
    Xs = np.linspace(np.min(x), np.max(x), Nx)
    Ys = np.linspace(np.min(y), np.max(y), Ny)
    xg, yg = np.meshgrid(Xs, Ys)
    values = np.zeros((Ny, Nx)) - np.min(d) - 1
        
    for i in range(Nx):
        for j in range(Ny):
            val = InterpolateValue(nodes, elements, d, np.array([xg[j,i], yg[j,i], z]))
            if not val is None:
                values[j,i] = val
            else:
                values[j,i] = None
            
    fig, ax = plt.subplots()    
    im = ax.contourf(xg, yg, values, np.linspace(np.min(d), np.max(d), 19),
                  origin='lower', cmap=cm.rainbow)
    ax.set_aspect('equal')
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.set_title(dataLabel + r"\P-D = {0:.0f} $\mu$m".format(z))
    ax.set_xlabel(r'A-P ($\mu$m)')
    ax.set_ylabel(r'V-D ($\mu$m)')
    ax.set_xlim(np.min(x), np.max(x))
    ax.set_ylim(np.min(y), np.max(y))
    plt.colorbar(im)
    plt.show()
    fig.savefig("./{0:s}_{1:d}.pdf".format(dataLabel, int(z)))
    
def GeneratePlots(x,y,z,d,dataLabel,zCut,resolution):
    print("Generating plots for '{0:s}'.".format(dataLabel))
    #Generate3DSurface(x,y,z,d,dataLabel, refineLevel=3)
    GeneratePlaneCuts(x,y,z,d,dataLabel,zCut,resolution)
    
if __name__ == "__main__":
    nodes = np.array([[0,0,0], [1,0,0], [0,1,0], [0,0,1.]])
    elements = np.array([[0,1,2,3]])
    point = np.array([.2,.2,.2])
    values = np.array([2.,1.,1.,1.])
    InterpolateValue(nodes, elements, values, point)
