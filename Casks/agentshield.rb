cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.464"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.464/agentshield_0.2.464_darwin_amd64.tar.gz"
      sha256 "b4705102005bf175291d3fe274dae565f08a03837beac38f4da3157ebdbe0c80"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.464/agentshield_0.2.464_darwin_arm64.tar.gz"
      sha256 "a45fa74458b8298b5d6e48c0dc8d331bde6c70ecff83dc9d77c3cf50e2a1e59a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.464/agentshield_0.2.464_linux_amd64.tar.gz"
      sha256 "d6b8bdd719cf43e74ed4a4c0586f6e5cb81523fce0f03100592dad3f6c736bce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.464/agentshield_0.2.464_linux_arm64.tar.gz"
      sha256 "f107bd65b5204349b6f6b9faa83c7a1fa2aeb6a4aedb1e30b0f30286c6990ee6"
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
