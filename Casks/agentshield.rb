cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.100"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.100/agentshield_0.2.100_darwin_amd64.tar.gz"
      sha256 "ffcd944f66b81ef57f94e15257772dfb63a2b04cbc327e0aedd9f80e934a01bf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.100/agentshield_0.2.100_darwin_arm64.tar.gz"
      sha256 "1bf5339eba1b978bf86b5acbb56a9d1289d42620cb8a84b1d62a709ddf3d74e0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.100/agentshield_0.2.100_linux_amd64.tar.gz"
      sha256 "88e57f079e360e5da73f9b6af6f7f3d901da6be1ed7fb54f7ca017931270f246"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.100/agentshield_0.2.100_linux_arm64.tar.gz"
      sha256 "9c5e8277e6eecb60047efd4469e5dc8fa301864f1cc025f7b54483cf04837f09"
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
