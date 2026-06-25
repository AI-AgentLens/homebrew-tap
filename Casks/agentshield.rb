cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1441"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1441/agentshield_0.2.1441_darwin_amd64.tar.gz"
      sha256 "4e74949a089f5ae2cba95ca52da0a15890fd96c70cb7fa0e8ab595ffb80b995d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1441/agentshield_0.2.1441_darwin_arm64.tar.gz"
      sha256 "4dae0f7b02f5628ab305032cb9309ff7afb19d251f786f93340c06b06c8f167d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1441/agentshield_0.2.1441_linux_amd64.tar.gz"
      sha256 "64d76bf6596b232b01ad39a5e1b8d996ba23f3ed895731a0045f9a7a37ad3bb3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1441/agentshield_0.2.1441_linux_arm64.tar.gz"
      sha256 "1c6c3fa589c93fa358da4d1cc808e9615c8ba2717d381e4d6f3652a6ba978dc7"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
