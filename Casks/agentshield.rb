cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1460"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1460/agentshield_0.2.1460_darwin_amd64.tar.gz"
      sha256 "a929c893534d74d37bded4e84e8639fb97ee21b968309b198d90f535c83c9254"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1460/agentshield_0.2.1460_darwin_arm64.tar.gz"
      sha256 "8490dff45f11b53d92899edc0390025094af3c5d44a4cdb99d62ccc4794d20f9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1460/agentshield_0.2.1460_linux_amd64.tar.gz"
      sha256 "3db4613683ac5e6f07955d47d719e0bac821831cc91b4187703fe83adfd461ef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1460/agentshield_0.2.1460_linux_arm64.tar.gz"
      sha256 "90f786f36d437084be3ee4e2702d7eebdd5e96c866830ade42d63ede2d788195"
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
