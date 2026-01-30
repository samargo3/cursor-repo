/**
 * @description Base controller for Salesforce Agent actions
 * @author Solution Engineering Team
 * @version 1.0
 */
public virtual with sharing class AgentActionController {
    
    /**
     * @description Base response structure for Agent actions
     */
    public class AgentResponse {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Object data { get; set; }
        @AuraEnabled public List<String> errors { get; set; }
        
        public AgentResponse() {
            this.success = false;
            this.errors = new List<String>();
        }
        
        public AgentResponse(Boolean success, String message) {
            this();
            this.success = success;
            this.message = message;
        }
        
        public AgentResponse(Boolean success, String message, Object data) {
            this(success, message);
            this.data = data;
        }
    }
    
    /**
     * @description Base action interface for Agent capabilities
     */
    public interface AgentAction {
        AgentResponse execute(Map<String, Object> parameters);
        String getActionName();
        String getDescription();
        List<String> getRequiredParameters();
    }
    
    /**
     * @description Utility method to validate required parameters
     */
    public static Boolean validateParameters(Map<String, Object> parameters, List<String> requiredParams) {
        if (parameters == null) return false;
        
        for (String param : requiredParams) {
            if (!parameters.containsKey(param) || parameters.get(param) == null) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * @description Utility method to create error response
     */
    public static AgentResponse createErrorResponse(String message, List<String> errors) {
        AgentResponse response = new AgentResponse(false, message);
        response.errors = errors;
        return response;
    }
    
    /**
     * @description Utility method to create success response
     */
    public static AgentResponse createSuccessResponse(String message, Object data) {
        return new AgentResponse(true, message, data);
    }
}
