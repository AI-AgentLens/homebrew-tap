cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1474"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1474/agentshield_0.2.1474_darwin_amd64.tar.gz"
      sha256 "0e636e57ae1ac840cabc8c20c9c54e1641e3a9d848c9c8ca5cf6736044b4038d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1474/agentshield_0.2.1474_darwin_arm64.tar.gz"
      sha256 "ac91a692069a69b1b7eac037c5b576984e3da3b1df5a6e353ff07dff7f1881b5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1474/agentshield_0.2.1474_linux_amd64.tar.gz"
      sha256 "da362e0c3c049567532b514ff5461ed7d9ae6f9b9b28d31e2fbbce383978e835"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1474/agentshield_0.2.1474_linux_arm64.tar.gz"
      sha256 "0aacda0c0b40ddd43d8663f5b9b8dcf93beecb5d72391ee03c2ba2a364eee4ac"
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
