cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1104"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1104/agentshield_0.2.1104_darwin_amd64.tar.gz"
      sha256 "3b7d577b280d1990be1660c619e697c5995767c94e15615830efe1fe51b728bb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1104/agentshield_0.2.1104_darwin_arm64.tar.gz"
      sha256 "46bdb72366abe9e92303fe2b67b66b0ec6b044f257c88fd97f88b20fb7b6e1d8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1104/agentshield_0.2.1104_linux_amd64.tar.gz"
      sha256 "272f02987253ba82fae30aac19dfeba3c81bc5c52bd58083fbb931ea96bfd171"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1104/agentshield_0.2.1104_linux_arm64.tar.gz"
      sha256 "acb353149c567fd83adf9bbfb9b86b14450b19b83eb4c2b1c76c7a8dbdeceb51"
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
