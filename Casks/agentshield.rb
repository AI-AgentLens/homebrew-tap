cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2129"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2129/agentshield_0.2.2129_darwin_amd64.tar.gz"
      sha256 "12263c53bae437b61bb266848c4822cb37bc8cb52af6b67a097a973cebb4b83c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2129/agentshield_0.2.2129_darwin_arm64.tar.gz"
      sha256 "b0a26b11467c431e18edb0f839ca7ffb2b462da89f1815caabd0f75d114af939"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2129/agentshield_0.2.2129_linux_amd64.tar.gz"
      sha256 "a71bbd21b79e9d0d4fa40591f7e2dae24f55c2299d01998d8a6a4ccfb212c4e7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2129/agentshield_0.2.2129_linux_arm64.tar.gz"
      sha256 "6b5b01b488f581b5b7dcb0d9932604dba35e7511ac87a8ceb7ecb5f9e788fac4"
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
