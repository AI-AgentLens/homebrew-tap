cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1034"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1034/agentshield_0.2.1034_darwin_amd64.tar.gz"
      sha256 "1955e460a0b21d5666b96d5770a6747e7a33cf1ce834e0d7cbbc70d0bd54db33"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1034/agentshield_0.2.1034_darwin_arm64.tar.gz"
      sha256 "7525fce98c7cbe9efa18a10541df329fdbe426b31e6ad01e1ae22209c61abe17"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1034/agentshield_0.2.1034_linux_amd64.tar.gz"
      sha256 "0fcc02cded38a864b14458bc289944633b1ecc9341ea785a3501ce339c3745aa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1034/agentshield_0.2.1034_linux_arm64.tar.gz"
      sha256 "c42f3a02138d814b0225d1b74cd6748bff866e2c4a63474d18f4ea386ee1e47f"
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
