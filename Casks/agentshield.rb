cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.849"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.849/agentshield_0.2.849_darwin_amd64.tar.gz"
      sha256 "c2147ebbf9903f3408dfc39b461f44600ad48ab8185a1998f13433795a63d2b7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.849/agentshield_0.2.849_darwin_arm64.tar.gz"
      sha256 "9520e1684ef5368df000c59b0d70050b195df38d625ce8e9ef8ccc752c2a4276"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.849/agentshield_0.2.849_linux_amd64.tar.gz"
      sha256 "16619d783c6cc92560f56ad73c3a9aa7b430e765f542cd76e39bdefe6e702f87"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.849/agentshield_0.2.849_linux_arm64.tar.gz"
      sha256 "03e35cf86202ac2f356ff976a59c6710dac23e40710a80bccd944c6ed554d577"
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
