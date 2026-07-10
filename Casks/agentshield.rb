cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1603"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1603/agentshield_0.2.1603_darwin_amd64.tar.gz"
      sha256 "8c1c44104e338277bc28035d1613d504a75ca6db3c5eb42fc021aa563d7d53b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1603/agentshield_0.2.1603_darwin_arm64.tar.gz"
      sha256 "5a7ea4b95eac821c4deb24a06b81b05459a3e15e9a36a7024773f7c822206558"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1603/agentshield_0.2.1603_linux_amd64.tar.gz"
      sha256 "0f225c3f9663143b50734c1723ea25ae449065701f5eee60923a1f55de1e9624"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1603/agentshield_0.2.1603_linux_arm64.tar.gz"
      sha256 "72c5a499bae43631e649b5d5ac6f221b337795ce6bede341cafe01ae16960da6"
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
