cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.468"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.468/agentshield_0.2.468_darwin_amd64.tar.gz"
      sha256 "0ec05a82ae5a5b6171025e166344756d251050d08986b0a19b6bc8c68a013626"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.468/agentshield_0.2.468_darwin_arm64.tar.gz"
      sha256 "a2329a391f4f976ee523008f9a58b93c281c84afac692a162ca041468cea8f99"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.468/agentshield_0.2.468_linux_amd64.tar.gz"
      sha256 "24ff8ed48535519ed0c2348fdd40280bed439bcd25d7bfc9fbc12e717f4548fd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.468/agentshield_0.2.468_linux_arm64.tar.gz"
      sha256 "e114e13562d61b2a9b219450e598417421e9c57d7cbc7f1277fdb59619c8038b"
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
