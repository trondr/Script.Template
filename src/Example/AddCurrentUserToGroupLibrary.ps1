
# User specified functions for use in the main script can be defined in this file.


###############################################################################
#
#   Inline C# class for handling Ad group operations
#
###############################################################################
$adOperationsClass = @'
using System;
using System.DirectoryServices;
using System.DirectoryServices.AccountManagement;
using log4net;
public class AdOperations
{
    public static ILog Logger
    {
        get
        {
            if(_logger == null)
            {
                _logger = LogManager.GetLogger("AdOperations"); 
            }   
            return _logger;
        }
    }
    private static ILog _logger;

    public static string GetUserDistinguishedName(string userName)
    {
        using(var domain = new PrincipalContext(ContextType.Domain))
        {
            using(var user = UserPrincipal.FindByIdentity(domain, userName))
            {
                return user != null ? user.DistinguishedName : null;
            }
        }
    }

    public static void AddUserToGroup(string userDn, string groupName)
    { 
        try 
        { 
            Logger.InfoFormat("Adding '{0}' to group '{1}'...", userDn, groupName);
            using (PrincipalContext pc = new PrincipalContext(ContextType.Domain))
            {
                using(GroupPrincipal group = GroupPrincipal.FindByIdentity(pc, groupName))
                {                                    
                    group.Members.Add(pc, IdentityType.DistinguishedName, userDn);
                    group.Save();
                }
            }
        } 
        catch(PrincipalExistsException ex)
        {
            Logger.Warn("User is allready member of the group. " + ex.Message);
        }
        catch (System.DirectoryServices.DirectoryServicesCOMException ex) 
        {             
            Logger.Error("Failed to add user to group. COM exception occured. " + ex.ToString());
            throw;
        } 
        catch(Exception ex)
        {
            Logger.Error("Failed to add user to group. " + ex.ToString());
            throw;
        }
    } 

    public static void RemoveUserFromGroup(string userDn, string groupName)
    {   
        try 
        { 
            Logger.InfoFormat("Removing '{0}' from group '{1}'...", userDn, groupName);
            using (PrincipalContext pc = new PrincipalContext(ContextType.Domain))
            {
                using(GroupPrincipal group = GroupPrincipal.FindByIdentity(pc, groupName))
                {
                    group.Members.Remove(pc, IdentityType.DistinguishedName, userDn);
                    group.Save();
                }
            }
        } 
        catch (System.DirectoryServices.DirectoryServicesCOMException ex) 
        {             
            Logger.Error("Failed to remove user from group. COM exception occured. " + ex.ToString());
            throw;
        } 
        catch(Exception ex)
        {
            Logger.Error("Failed to remove user from group. " + ex.ToString());
            throw;
        }
    }
}
'@
$referencedAssemblies = "System.DirectoryServices.dll", "System.DirectoryServices.AccountManagement.dll" , $log4NetDll
Add-Type -TypeDefinition $adOperationsClass -Language CSharpVersion3 -ReferencedAssemblies $referencedAssemblies

###############################################################################
#
#   Functions using the inline C# AdOperations class
#
###############################################################################

#function GetUserDistinguishedName([string] $userName)
#{
#    $userDn = [AdOperations]::GetUserDistinguishedName($userName)
#    return $userDn
#}

function GetCurrentUserDistinguishedName
{
    $userDn = [AdOperations]::GetUserDistinguishedName($env:USERNAME)
    return $userDn
}

function AddCurrentUserToGroup([string] $groupName)
{
    $userDn = GetCurrentUserDistinguishedName
    [AdOperations]::AddUserToGroup($userDn , $groupName)
}

function RemoveCurrentUserFromGroup([string] $groupName)
{
    $userDn = GetCurrentUserDistinguishedName
    [AdOperations]::RemoveUserFromGroup($userDn , $groupName)
}

