cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2244"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2244/agentshield_0.2.2244_darwin_amd64.tar.gz"
      sha256 "b0fb8c4446843eed1e4fd409ba5b2e2834a4a9104abf1a2bbe6b30ff99464bcc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2244/agentshield_0.2.2244_darwin_arm64.tar.gz"
      sha256 "ebe3ad968e96ed68ab684238a5389a8611cf496925d339c865b76ca021fbd532"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2244/agentshield_0.2.2244_linux_amd64.tar.gz"
      sha256 "32fb3506f3ef07339670e13ff12d02bf1dfcf09e61c7109ec9186642cdd0284f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2244/agentshield_0.2.2244_linux_arm64.tar.gz"
      sha256 "f7bcc144876d02b4c6e88172790ce2806d3efecf51babd651fed5f0705d785db"
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
