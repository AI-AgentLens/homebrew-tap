cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.936"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.936/agentshield_0.2.936_darwin_amd64.tar.gz"
      sha256 "9e45015efe4bc09626f58eb3dd8c209657e545d958e3feba78d71d8c88f79175"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.936/agentshield_0.2.936_darwin_arm64.tar.gz"
      sha256 "d4bbc65471cf1ac6e285c4261f3b4b67487634a8f474f9362610b87463b7719b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.936/agentshield_0.2.936_linux_amd64.tar.gz"
      sha256 "6dcf355d98077abdf4085c6d1193bbe78bbd0fb334159e6aca1d077da5d2efa2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.936/agentshield_0.2.936_linux_arm64.tar.gz"
      sha256 "0390c1d72494034f2f19005eafb2cb4c36ef559a2cb3e138325d0d59a1197fb3"
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
