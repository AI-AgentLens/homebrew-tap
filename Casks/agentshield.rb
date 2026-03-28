cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.164"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.164/agentshield_0.2.164_darwin_amd64.tar.gz"
      sha256 "b4d8bb4fe5234df152a1087f536051ed6361e3422b02ba0d20f7e77962b4385a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.164/agentshield_0.2.164_darwin_arm64.tar.gz"
      sha256 "c127a807636146416aa1dc4ce07b138c1d19ed8de132ad605a8ca87b7c18e04a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.164/agentshield_0.2.164_linux_amd64.tar.gz"
      sha256 "d4d19d4480fef4bce8f830fef9c7d12924f6ae0140af2b161c205909dd642e69"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.164/agentshield_0.2.164_linux_arm64.tar.gz"
      sha256 "007119bda9b43138d817c6e9342f15316cf1138ce1496d925460d91230b339a8"
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
