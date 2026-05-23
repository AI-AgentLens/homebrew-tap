cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1095"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1095/agentshield_0.2.1095_darwin_amd64.tar.gz"
      sha256 "0d874371cdfc2cdbe41fb887cb17442195d460ade5b432cb328f5a94c8173943"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1095/agentshield_0.2.1095_darwin_arm64.tar.gz"
      sha256 "d79c6aca37b9b8e3e82f4b94d064da5118725b4713030ca50c7f06d57e5ef935"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1095/agentshield_0.2.1095_linux_amd64.tar.gz"
      sha256 "935919a34c9afa94f3c20ed8665c9964e922fbdb7daf63665c794a703aee354f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1095/agentshield_0.2.1095_linux_arm64.tar.gz"
      sha256 "66949d64a0547c8a3c7d83fae89a812f21685f82691e9e8c3d707bfcd351b0c8"
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
