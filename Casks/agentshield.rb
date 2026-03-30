cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.229"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.229/agentshield_0.2.229_darwin_amd64.tar.gz"
      sha256 "f15b43e1ecce34af6f22856161310dd1eb4542d5bf0fa849b5eb240578770f91"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.229/agentshield_0.2.229_darwin_arm64.tar.gz"
      sha256 "9a4a954248e2aaa66d248eaff0da7b5b92ef4f70fd8178ec5cb76e8b863b2571"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.229/agentshield_0.2.229_linux_amd64.tar.gz"
      sha256 "07a7c70426e5ab7c69097588061661588689daf56ce6d39a9a68cd4d0dcd5b6a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.229/agentshield_0.2.229_linux_arm64.tar.gz"
      sha256 "c0c679a251e50652f1cb03dbc215682581a8548a4ddb83c7817034b9ba3146be"
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
