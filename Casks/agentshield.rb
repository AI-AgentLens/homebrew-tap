cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.811"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.811/agentshield_0.2.811_darwin_amd64.tar.gz"
      sha256 "f840d5f98f126023c765af0226000509f22dbca6cf6183718ea29d0843a80936"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.811/agentshield_0.2.811_darwin_arm64.tar.gz"
      sha256 "7a00f446d72fc97c1b3e0ed6643557831e7927d50c0eb3ea0cf0056b9538fe7e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.811/agentshield_0.2.811_linux_amd64.tar.gz"
      sha256 "685ed3b638f19d908daeeb8ecbd516e28a3851c43760a66bc65a331de2c06d41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.811/agentshield_0.2.811_linux_arm64.tar.gz"
      sha256 "c8395d3ae6e5c84fd10dc7440c8a290e51b0a3a1921195cff2c033f2390ffa40"
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
